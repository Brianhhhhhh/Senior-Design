
    #define BOARD_WIDTH 640                      // window height
    #define BOARD_HEIGHT 480                     // window width
    #define NET_X 306                           // net x pos
    #define BALL_DIAMETER 8                        // ball radius
    #define BALL_RADIUS 4                        // ball radius
    #define HALF_PADDLE_HEIGHT 17                // half of the paddle height
    #define PADDLE_HEIGHT 35                // half of the paddle height
    #define HALF_PADDLE_WIDTH 4                  // half of the paddle width
    #define PADDLE_WIDTH 8                  // half of the paddle width
    #define PADDLE_SPACING 20                     // Spacing between paddle and board edge
    #define BOUNDARY 1                           // left and right boundary
    #define SCORE_1_X 150                           // left and right boundary
    #define SCORE_2_X 500                           // left and right boundary
    #define HUMAN_SPEED 1                        // Speed of human player
    // Control paddle by human player, with sensor distance d
    #define THRESHOLD1 100                        // Move down fast (0<d<50)
    #define THRESHOLD2 200                       // Move down slow (50<d<100)
    #define THRESHOLD3 300                       // Not moving (100<d<150)
    #define THRESHOLD4 400                       // Move up slow (150<d<200)
    #define THRESHOLD5 600                       // Move up fast (200<d<250)
    #define PADDLE_SPEED_FAST 2                  // Paddle speed (fast)
    #define PADDLE_SPEED_SLOW 1                  // Paddle speed (slow)
    // Memory mappings
    #define LED_REG 49152                        // LED REG
    #define BMP_CTL 49160                        // starts a placement of an image
    #define BMP_XLOC 49161                       // X-location of upper left corner
    #define BMP_YLOC 49162                       // Y-location of upper left corner
    #define BMP_STAT 49163                       // A read from this returns {15’h0000,busy}
    #define PIEZO_REG 49165                      // A write to this reg starts the buzzer

#define square(x) ((x) * (x))
#define abs(x) ((x) < 0 ? -(x) : (x))

/* Structure of the board:

   0            ...           640

   .
   .            ...
   .

   480          ...        (640, 480)

*/

typedef struct ball_s {
    float x;
    float y;                                  // position of the ball
    float dx;
    float dy;                                // movement vector
} ball_t;

typedef struct paddle {
    int x, y;                                    // position of the paddle
} paddle_t;

// Program globals
ball_t ball = {0,0,0,0};
paddle_t paddle[2] = {{0,0},{0,0}};
int score[] = {0, 0};
int collision = 0;
int win = 0;
// int start_dx = 1;


// Keep checking BMP_STAT
void wait_busy() {
    int *mem_addr = (int *) BMP_STAT;
    volatile int stat = *mem_addr;
    while ((stat & 0x1)) {
        stat = *mem_addr;
    }
}

void clear_screen(){
    int x_loc = 0;
    int *mem_addr;

    while(x_loc != 672){

        // Display net
        mem_addr = (int *) BMP_XLOC;
        *mem_addr = x_loc;            // half net width = 14
        mem_addr = (int *) BMP_YLOC;
        *mem_addr = 0;
        mem_addr = (int *) BMP_CTL;
        wait_busy();
        *mem_addr = 32;                              // Binary: 0000 0000 0100 0000
        *mem_addr = 0;                               // Set to 0
        x_loc += 28;
    }
}

void init_game() {

    ball.x = BOARD_WIDTH / 2;
    ball.y = BOARD_HEIGHT / 2;
    ball.dy = 0;
    ball.dx = 3;

    paddle[0].x = PADDLE_SPACING;
    paddle[0].y = BOARD_HEIGHT / 2;
    paddle[1].x = BOARD_WIDTH - PADDLE_SPACING;
    paddle[1].y = BOARD_HEIGHT / 2;
    clear_screen();

}

void update_score(){
    // Has the following bit mapping: {add_fnt,fnt_indx[5:0],2’b00,add_img,rem_img,image_index[4:0]}
    int *mem_addr;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = SCORE_1_X;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = 0;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = (0x8000 | (score[0] << 9));                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;                           // Set to 0

    mem_addr = (int *) BMP_XLOC;
    *mem_addr = SCORE_2_X;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = 0;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = (0x8000 | (score[1] << 9));                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;                           // Set to 0
}

void check_score() {
    if(score[0] == 10){
        // score[0] = 9;
        // update_score();
        win = 1;
        while(1){};
    }
    if(score[1] == 10){
        // score[1] = 9;
        // update_score();
        win = 1;
        while(1){};
    }
}

// Sound number should between 0 and 3
void buzzer(int sound) {
    // return;
    int *mem_addr;
    mem_addr = (int *) PIEZO_REG;
    // {13’h0000, piezo_index[1:0], start_buzzer}
    *mem_addr = (sound * 2 + 1);
    *mem_addr = 0;
}

// Wait for certain period of time
void wait_spinning() {
    int i = 0;
    while (i++ < 80000);                        // Spinning
}

// // If return value is 1 collision occured. If return is 0, no collision.
// int check_collision(int paddle_y) { //1 for left, 0 for right
//     if((ball.y < (paddle_y + PADDLE_HEIGHT)) & ((ball.y + BALL_DIAMETER) > paddle_y))
//         return 1;
//     else
//         return 0;

// }
void check_collision(int i) {


    int left_a, left_b, right_a, right_b, top_a, top_b, bottom_a, bottom_b;
    collision = 0;

    left_a   = (int) ball.x;
    right_a  = (int) ball.x + BALL_DIAMETER;
    top_a    = (int) ball.y;
    bottom_a = (int) ball.y + BALL_DIAMETER;
    left_b   = paddle[i].x;
    right_b  = paddle[i].x + PADDLE_WIDTH;
    top_b    = paddle[i].y;
    bottom_b = paddle[i].y + PADDLE_HEIGHT;

    if ((left_a - right_b) > 0)
        return;
    if ((left_b - right_a) > 0)
        return;
    if ((top_a - bottom_b) > 0)
        return;
    if ((top_b - bottom_a) > 0)
        return;
    collision = 1;

}



void clear_old_images() {

    int *mem_addr;

    // clear paddles
    int i = 0;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 33;                          // Binary: 0000 0000 0010 0001
    *mem_addr = 0;                           // Set to 0
    i = i + 1;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 33;                          // Binary: 0000 0000 0010 0001
    *mem_addr = 0;

    // Display ball
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = ball.x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = ball.y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 34;                              // Binary: 0000 0000 0010 0010
    *mem_addr = 0;                               // Set to 0


}

// This routine moves the ball by its velocity vector.
void move_ball() {

    //remove the old ball
    int* mem_addr;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = ball.x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = ball.y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 34;                              // Binary: 0000 0000 0001 0010
    *mem_addr = 0;                               // Set to 0

    // Move the ball by its velocity vector.
    ball.x += ball.dx;
    ball.y += ball.dy;

    if (((int) ball.y <= BOUNDARY) || ((int) ball.y >= (450))) {
    // if (((int) ball.y == BOUNDARY) || ((int) ball.y == (450))) {
    // static int i = 0;
    // if ((i += 1) % 5 == 0) {
        ball.dy = (-1) * ball.dy;
        buzzer(0);
        // int* mem_addr;
        mem_addr = (int *) LED_REG;
        *mem_addr = 3;
    }
    // return;


    // Player 1 scored if ball hits the left edge
    if ((int) ball.x <= (BALL_DIAMETER + BOUNDARY)) {
        score[1] += 1;
        buzzer(1);
        wait_spinning();
        clear_old_images();
        init_game();
        // int* mem_addr;
        mem_addr = (int *) LED_REG;
        *mem_addr = 1;
        // start_dx = -1;

        // print_score();
    }
    // Player 0 scored if ball hits the right edge
    if ((int) ball.x >= (BOARD_WIDTH - BOUNDARY)) {
        score[0] += 1;
        buzzer(1);
        wait_spinning();
        clear_old_images();
        init_game();
        // int* mem_addr;
        mem_addr = (int *) LED_REG;
        *mem_addr = 2;
        // start_dx = 1;
        // print_score();
    }

    // Turn the ball around if it hits the edge of the screen

    // *mem_addr = 4;

    int i = 0;
    if(collision & 0x1){
        collision = 0;
        return;
    }
    check_collision(i);
    if (collision & 0x1) {
        buzzer(0);
        // Get the hit position, and then convert from [-25, 25] to [-1, 1]
        ball.dy = (ball.y - paddle[i].y + BALL_RADIUS - HALF_PADDLE_HEIGHT) / HALF_PADDLE_HEIGHT;
        // Calculate the absolute value of new x-velocity
        float new_dx = 3 - ball.dy * ball.dy / 2;
        // Reverse the horizontal direction of the ball
        if(score[0] > 5 | score[1] > 5){
            new_dx = new_dx + 2;
        }
        if (ball.dx < 0)
            ball.dx = abs(new_dx);
        else
            ball.dx = - abs(new_dx);
    }
    i = 1;
    check_collision(i);
    if (collision & 0x1) {
        buzzer(0);
        // // Get the hit position, and then convert from [-25, 25] to [-1, 1]
        // ball.dy = (ball.y - paddle[i].y + BALL_RADIUS - HALF_PADDLE_HEIGHT) / HALF_PADDLE_HEIGHT;
        // // Calculate the absolute value of new x-velocity
        // float new_dx = 1 - ball.dy * ball.dy / 2;
        // // Reverse the horizontal direction of the ball
        // if (ball.dx < 0)
        //     ball.dx = new_dx;
        // else
        ball.dy = (ball.y - paddle[i].y + BALL_RADIUS - HALF_PADDLE_HEIGHT) / HALF_PADDLE_HEIGHT;
        // Calculate the absolute value of new x-velocity
        float new_dx = 3 - ball.dy * ball.dy / 2;
        // Reverse the horizontal direction of the ball
        if(score[0] > 5 | score[1] > 5){
            new_dx = new_dx + 2;
        }
        if (ball.dx < 0)
            ball.dx = abs(new_dx);
        else
            ball.dx = - abs(new_dx);
    }

}
    // i = 1;
    // if (check_collision(ball, paddle[i])) {
    //     buzzer();
    //     // Get the hit position, and then convert from [-25, 25] to [-1, 1]
    //     ball.dy = (ball.y - paddle[i].y) / HALF_PADDLE_HEIGHT;
    //     // Calculate the absolute value of new x-velocity
    //     int new_dx = 1 - ball.dy * ball.dy / 2;
    //     // Reverse the horizontal direction of the ball
    //     if (ball.dx < 0)
    //         ball.dx = new_dx;
    //     else
    //         ball.dx = - new_dx;
    // }



// Move the paddle controlled by human player
void move_paddle_human(int human_player) {
    // int human_player = 0;
    int *mem_addr;
    if (human_player & 0x1)
        mem_addr = (int *) 49166;                        // 0xC00F
    else
        mem_addr = (int *) 49167;                        // 0xC00E
    int hand_position = *mem_addr;
    hand_position = hand_position & 0xffff;

    // The postion of hand will control the paddle direction and speed.
    if (hand_position < THRESHOLD1){
        if(paddle[human_player].y < (430))
            paddle[human_player].y += PADDLE_SPEED_FAST;
    }
    else if (hand_position < THRESHOLD2){
        if(paddle[human_player].y < (430))
            paddle[human_player].y += PADDLE_SPEED_SLOW;
    }
    // else if (0)
    else if (hand_position < THRESHOLD3){
        paddle[human_player].y += 0;
    }
    // else if (1)
    else if (hand_position < THRESHOLD4){
        if(paddle[human_player].y > (0))
            paddle[human_player].y -= PADDLE_SPEED_SLOW;
    }
    // else if (0)
    else if (hand_position < THRESHOLD5){
        if(paddle[human_player].y > (0))
            paddle[human_player].y -= PADDLE_SPEED_FAST;
    }
    // If the hand position is too large (i.e. above Threshold 5), we consider
    // it as hand not detected. Then the paddle will not move.

}

// Show the board on the real screen
void init_board_screen() {

    int *mem_addr;

    // Display net
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = NET_X;            // half net width = 14
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = 0;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 64;                              // Binary: 0000 0000 0100 0000
    *mem_addr = 0;                               // Set to 0

    // Display paddle
    int i = 0;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;                           // Set to 0
    i = i + 1;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;

    // Display ball
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = ball.x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = ball.y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 66;                              // Binary: 0000 0000 0100 0010
    *mem_addr = 0;                               // Set to 0

    // TODO: display font for player scores

}

// Update ball and paddle
void update_board_screen() {

    int *mem_addr;

    // Display net
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = NET_X;            // half net width = 14
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = 0;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 64;                              // Binary: 0000 0000 0100 0000
    *mem_addr = 0;                               // Set to 0

    // Refresh paddle
    int i = 0;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;                           // Set to 0
    i = i + 1;
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = paddle[i].x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = paddle[i].y;
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 65;                          // Binary: 0000 0000 0100 0001
    *mem_addr = 0;

    // Move old ball
    mem_addr = (int *) BMP_XLOC;
    *mem_addr = ball.x;
    mem_addr = (int *) BMP_YLOC;
    *mem_addr = ball.y;
    // wait_busy();
    // mem_addr = (int *) BMP_CTL;
    // *mem_addr = 34;                              // Binary: 0000 0000 0010 0010
    // *mem_addr = 0;                               // Set to 0
    // Draw new ball
    mem_addr = (int *) BMP_CTL;
    wait_busy();
    *mem_addr = 66;                              // Binary: 0000 0000 0100 0010
    *mem_addr = 0;                               // Set to 0

}

// void clear_screen(){}



int main() {
    while(1){
        score[0] = 0;
        score[1] = 0;
        init_game();
        update_score();
        // init_board_screen();
        // while(1);
        win = 0;

        while (1) {
            move_paddle_human(0);
            move_paddle_human(1);
            move_ball();
            update_board_screen();
            update_score();
            // check_score();
            wait_spinning();

            if(score[0] == 10 | score[1] == 10){
                while(1){};
            }
        }

        // TODO: show winner with font/image
    }


}