#define AF_INET 2
#define SOCK_STREAM 1
#define IPPROTO_TCP 6
#define SO_REUSEADDR 2
#define SOL_SOCKET 1
#define SHUT_RDWR 2
#define O_RDONLY 0

typedef unsigned short uint16_t;

/* must be padded to at least 16 bytes */
typedef struct {
  uint16_t sin_family; /* 2 */
  uint16_t sin_port;   /* 4 -> this is in big endian */
  int sin_addr;        /* 8 */
  char sin_zero[8];    /* 16 */
} sockaddr_in_t;

int write(int fd, void* buf, int buf_len);
int read(int fd, void* buf, int buf_len);
int socket(int domain, int type, int protocol);
int bind(int socket, void* address, int address_len);
int listen(int socket, int backlog);
int accept(int socket, void* address, int address_len);
int close(int fd);
int fork();
int setsockopt(int socket, int level, int option_name,
  void* val, int val_len);
void exit(int code);
int shutdown(int socket, int how);
int open(char* path, int flags);

/* this is fine because forked processes are copy on write */
/* so there shouldn't be any data races */
char http_buf[8192];

int strlen(char* s) {
  char* p;
  for (p = s; *p; ++p);
  return p - s;
}

uint16_t swap_uint16(uint16_t x) {
  return (
    ((x << 8) & 0xFF00) |
    ((x >> 8) & 0x00FF)
  );
}

#define fprint(fd, s) \
  write(fd, s, strlen(s))

#define fprintln(fd, s) \
  fprint(fd, s "\n")

#define print(s) \
  fprint(1, s)

#define println(s) \
  fprintln(1, s)

#ifdef DEBUG
#define die(s) \
  println("FATAL: " s); \
  exit(1)

#define perror(s) \
  println("ERROR: " s)
#else
#define die(s) exit(1)
#define perror(s)
#endif

int tcp_listen(int port) {
  static int yes = 1;
  static sockaddr_in_t addr;
  int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (sock < 0) {
    die("socket");
  }
  setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
  /* address is zero = any address */
  addr.sin_family = AF_INET;
  addr.sin_port = swap_uint16(port);
  if (bind(sock, &addr, sizeof(addr)) < 0) {
    die("bind");
  }
  if (listen(sock, 10) < 0) {
    die("listen");
  }
  return sock;
}

/*
 * must read the entire request otherwise some clients misbehave
 * http request ends with an empty line
 * line separator is \r\n but might as well handle \n aswell
 */

int isspace(char c) {
  switch (c) {
    case '\r':
    case ' ':
    case '\t':
      return 1;
  }
  return 0;
}

void http_consume(int clientfd) {
  int n;
  int total = 0;
  char* p;
  char* buf = http_buf;
  char* last_line = buf;
  while (1) {
    n = read(clientfd, buf, sizeof(http_buf) - (buf - http_buf) - 1);
    if (n > 0) {
      buf[n] = 0;
      buf += n;
      total += n;
    } else {
      if (n < 0) {
        perror("read");
      }
      break;
    }
    /* iterate lines, look for empty line */
    for (p = last_line; p < http_buf + total; ++p) {
      for (; *p && isspace(*p); ++p);
      if (*p == '\n') {
        /* all whitespace line */
        write(1, http_buf, total);
        return;
      }
      /* skip rest of the line */
      for (; *p && *p != '\n'; ++p);
      /* micro optimization: save last line start */
      last_line = p;
    }
  }
}

void http_drop(int clientfd) {
  shutdown(clientfd, SHUT_RDWR);
  close(clientfd);
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

#define http_code(fd, x) \
  fprint(fd, "HTTP/1.1 " x "\r\n\r\n" x);

int http_serve(int clientfd, char* file_path) {
  int f;
  char* buf = http_buf;
  http_consume(clientfd);
  fprint(clientfd, "HTTP/1.1 200 OK\r\n\r\n");
  f = open(file_path, O_RDONLY);
  if (f < 0) {
    perror("open");
    http_code(clientfd, "404 Not Found");
    return 1;
  }
  while (1) {
    int n = read(f, buf, sizeof(http_buf));
    if (n > 0) {
      if (write(clientfd, buf, n) < 0) {
        perror("write");
        return 1;
      }
    } else {
      if (n < 0) {
        perror("read");
      }
      break;
    }
  }
  http_drop(clientfd);
  return 0;
}

int atoi(char* s) {
  int res = 0;
  for (; *s; ++s) {
    if (*s > '9' || *s < '0') {
      return 0;
    }
    res = res * 10 + *s - '0';
  }
  return res;
}

void usage(char* self) {
  print("usage: ");
  print(self);
  println(" port file");
  exit(1);
}

int main(int argc, char* argv[]) {
  int sock;
  int port;
  if (argc != 3) {
    usage(argv[0]);
  }
  port = atoi(argv[1]);
  if (!port) {
    usage(argv[0]);
  }
  sock = tcp_listen(port);
  while (1) {
    int pid;
    int clientfd = accept(sock, 0, 0);
    if (clientfd < 0) {
      perror("accept");
      continue;
    }
    pid = fork();
    if (!pid) {
      return http_serve(clientfd, argv[2]);
    }
    if (pid < 0) {
      perror("fork");
      continue;
    }
  }
  return 0;
}
