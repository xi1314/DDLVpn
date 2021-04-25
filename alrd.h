#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void run_with_mode(const char *app_mode,
                   const char *http_address,
                   const char *socks_address,
                   const char *fake_dns_address,
                   const char *fake_pool,
                   const char *log_level,
                   const char *proxy_url,
                   const char *up_dns_address,
                   const char *domain_rules,
                   const char *ip_rules,
                   const char *tun_fd);

void test_log(const char *app_mode,
              const char *http_address,
              const char *socks_address,
              const char *fake_dns_address,
              const char *fake_pool,
              const char *log_level,
              const char *proxy_url,
              const char *up_dns_address,
              const char *domain_rules,
              const char *ip_rules,
              const char *tun_fd);

void stop(void);

const char *get_http_addr(void);

const char *get_socks_addr(void);

const char *get_fake_dns_addr(void);
