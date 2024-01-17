#define AF_INET 2
#define SOCK_STREAM 1
#define IPPROTO_TCP 6
#define SO_REUSEADDR 2
#define SOL_SOCKET 1
#define O_RDONLY 0

typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned int size_t;
typedef unsigned int socklen_t;
typedef int ssize_t;

/* must be padded to at least 16 bytes */
typedef struct {
  uint16_t sin_family; /* 2 */
  uint16_t sin_port;   /* 4 -> this is in big endian */
  uint32_t sin_addr;   /* 8 */
  char sin_zero[8];    /* 16 */
} sockaddr_in_t;

ssize_t read(int fd, void *buf, size_t nbyte);
ssize_t write(int fd, const void *buf, size_t nbyte);
int open(const char *path, int flags);
int close(int fd);
int socket(int domain, int type, int protocol);
int accept(int socket, sockaddr_in_t *restrict address,
           socklen_t *restrict address_len);
int bind(int socket, const sockaddr_in_t *address, socklen_t address_len);
int listen(int socket, int backlog);
int setsockopt(int socket, int level, int option_name, const void *option_value,
               socklen_t option_len);
int fork();
void exit(int status);

static size_t strlen(const char *s) {
  const char *p = s;
  while (*p)
    ++p;
  return p - s;
}

static uint16_t swap_uint16(uint16_t x) {
  return (((x << 8) & 0xFF00) | ((x >> 8) & 0x00FF));
}

#define fprint(fd, s) write(fd, s, strlen(s))

#define fprintn(fd, s, n) write(fd, s, n)

#define fprintl(fd, s) fprintn(fd, s, sizeof(s) - 1)

#define fprintln(fd, s) fprintl(fd, s "\n")

#define print(s) fprint(1, s)

#define printn(s, n) fprintn(1, s, n)

#define printl(s) fprintl(1, s)

#define println(s) fprintln(1, s)

#ifdef DEBUG
#define die(s)                                                                 \
  println("FATAL: " s);                                                        \
  exit(1)

#define perror(s) println("ERROR: " s)
#else
#define die(s) exit(1)

#define perror(s)
#endif

int tcp_listen(const sockaddr_in_t *addr, const void *option_value,
               socklen_t option_len) {
  int sock;
  if ((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0 ||
      setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, option_value, option_len) ||
      bind(sock, addr, sizeof(sockaddr_in_t)) || listen(sock, 10)) {
    die("listen");
  }
  return sock;
}

static void http_consume(int clientfd, char *http_buf, size_t buf_len) {
  int n;
  while ((n = read(clientfd, http_buf, buf_len)) > 0) {
    printn(http_buf, n);
    const char *p = http_buf + (n - 3);
    if (n < 3 || (*p == '\n' && *(p + 1) == '\r' && *(p + 2) == '\n')) {
      return;
    }
  }
  if (n < 0) {
    perror("read");
  }
}

/*
 * we're supposed to send content-length but shutting down the
 * socket seems to be enough, saves some code
 *
 * a http server is usually expected to respond to HEAD
 * requests without sending the actual content, we're not gonna
 * do that just to keep it tiny
 *
 * also, we could cache the file in memory instead of opening
 * it every time but since this is an exercise in making tiny
 * binaries it also makes sense to keep the mem usage low
 */

#define http_code(fd, x) fprintl(fd, "HTTP/1.1 " x "\r\n\r\n" x);

static int http_serve(int clientfd, const char *file_path, char *http_buf,
                      size_t buf_len) {
  int f, n;
  http_consume(clientfd, http_buf, buf_len);
  if ((f = open(file_path, O_RDONLY)) < 0) {
    perror("open");
    http_code(clientfd, "404 Not Found");
    return 1;
  }
  fprintl(clientfd, "HTTP/1.1 200 OK\r\n\r\n");
  while ((n = read(f, http_buf, buf_len)) > 0) {
    if (write(clientfd, http_buf, n) < 0) {
      perror("write");
      return 1;
    }
  }
  if (n < 0) {
    perror("read");
  }
  return 0;
}

static uint16_t string2port(const char *s) {
  uint16_t res = 0;
  for (; *s; ++s) {
    if (*s > '9' || *s < '0') {
      return 0;
    }
    res = res * 10 + *s - '0';
  }
  return swap_uint16(res);
}

static void usage(const char *self) {
  printl("usage: ");
  print(self);
  println(" port file");
  exit(1);
}

int main(int argc, char *argv[]) {
  int sock;
  uint16_t port;
  char http_buf[8192];
  if (argc != 3 || (port = string2port(argv[1])) == 0) {
    usage(argv[0]);
  }
  const int yes = 1;
  const sockaddr_in_t addr = {AF_INET, port, 0};
  sock = tcp_listen(&addr, &yes, sizeof(yes));
  while (1) {
    int pid, clientfd;
    if ((clientfd = accept(sock, 0, 0)) < 0) {
      perror("accept");
    } else if ((pid = fork()) < 0) {
      perror("fork");
    } else if (pid == 0) {
      return http_serve(clientfd, argv[2], http_buf, sizeof(http_buf));
    }
    close(clientfd);
  }
  return 0;
}
