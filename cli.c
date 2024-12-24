#include <stdint.h>

extern int uart0_rx_len();
//extern int uart0_tx_len();
extern int uart0_read_byte();

#define cli_buffer_len 127
#define MIN(x, y) ((x)<(y)?(x):(y))

char cli_buffer[cli_buffer_len+1];
int cli_buffer_cur = 0;

int cli_read()
{
  int bytes_in_rx = uart0_rx_len();
  if (bytes_in_rx == 0) return 0;
  int bytes_free = cli_buffer_len - cli_buffer_cur;
  for (int i=0; i<MIN(bytes_free, bytes_in_rx); i++) {
    char c = uart0_read_byte();
    switch (c) {
      case '\0':
      case 13:
      case 10:
        int len = cli_buffer_cur;
        cli_buffer[cli_buffer_cur] = 0;
        cli_buffer_cur = 0;
        return len;
      case '\b':
        if (cli_buffer_cur > 0) cli_buffer_cur--;
      break;
      default:
        cli_buffer[cli_buffer_cur] = c;
        cli_buffer_cur++;
    }
  }
  if (cli_buffer_len == cli_buffer_cur) {
    cli_buffer[cli_buffer_len] = 0;
    cli_buffer_cur = 0;
    return cli_buffer_len;
  }
  else return 0;
}
