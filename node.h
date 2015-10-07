typedef struct node{
    int note, octave, duration;
    int ishalf;
    struct node* next;
} Node;
