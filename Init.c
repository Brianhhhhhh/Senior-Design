// Keep checking 49163
void wait_busy() {

    int *mem_addr = (int *) 49163;
    volatile int stat = *mem_addr;
    while (stat != 0) {
        stat = *mem_addr;
    }

}

void wait_stop() {

    int *mem_addr = (int *) 0;
    while (1) {
        *mem_addr = 1;
    }

}

// Show the board on the real screen
int main() {

    int *mem_addr;

    // Display net
    mem_addr = (int *) 49161;
    *mem_addr = 600;            // half net width = 14
    mem_addr = (int *) 49162;
    *mem_addr = 0;
    mem_addr = (int *) 49160;
    // wait_busy();
    *mem_addr = 64;                              // Binary: 0000 0000 0100 0000
    *mem_addr = 0;                               // Set to 0

    // Display paddle
    wait_busy();
    mem_addr = (int *) 49161;
    *mem_addr = 25;
    mem_addr = (int *) 49162;
    *mem_addr = 300;
    mem_addr = (int *) 49160;
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;                           // Set to 0
    
    wait_busy();
    mem_addr = (int *) 49161;
    *mem_addr = 600;
    mem_addr = (int *) 49162;
    *mem_addr = 34;
    mem_addr = (int *) 49160;
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;   

    // Display ball
    wait_busy();
    mem_addr = (int *) 49161;
    *mem_addr = 200;
    mem_addr = (int *) 49162;
    *mem_addr = 200;
    mem_addr = (int *) 49160;
    *mem_addr = 66;                              // Binary: 0000 0000 0100 0010
    *mem_addr = 0;                               // Set to 0

    // TODO: display font for player scores
    wait_stop();

}