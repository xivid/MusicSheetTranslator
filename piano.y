%{
#include <stdio.h>
#include <memory.h>
#include <stdlib.h>

typedef struct node{
    int note, octave, duration;
    int ishalf, ishalfend;
    struct node* next;
} Node;

void yyerror(char *);
int yylex(void);
Node* newNode(int note, int octave);
void makeHalf(Node* head);
void printStmt(Node* head);
void connectNode(Node* e1, Node* e2);

const char octave[][8] = {"890qwer", "tyuiopa", "sdfghjk"};
%}

%union {
    int iVal;
    Node* pNode;
};

%token <iVal> NOTE VARIABLE INTEGER

%type <pNode> stmt expr note

%%
song:
    song stmt '\n' { printf("reduced to a song, output %p: \n", $2); printStmt($2); }
    |
    ;

stmt:
    expr stmt { $$ = $1; connectNode($1, $2); printf("reduced to a stmt, $2=%p\n", $2); }
    | {$$ = NULL; printf("epsilon stmt\n"); }
    ;

expr:
    note expr { $$ = $1; $1->next = $2; printf("expr: %d ++ %p\n", $1->note, $2); }
    | note '-' { $$ = $1; $1->duration = 2; printf("expr: %d-\n", $1->note); }
    | note '-' '-' { $$ = $1; $1->duration = 3; printf("expr: %d--\n", $1->note); }
    | note '-' '-' '-' { $$ = $1; $1->duration = 4; printf("expr: %d---\n", $1->note); }
    | '[' expr ']' { $$ = $2; makeHalf($2); printf("expr: []\n"); }
    | { $$ = NULL; printf("epsilon expr\n"); } 
    //can identify if (ret==NULL) ..->end = .. else ..->end = ..->next->end
    ;

note:
    NOTE { $$ = newNode($1, 1); printf("new node: %d %p\n", $1, $$); }
    | '_' NOTE { $$ = newNode($2, 0); printf("new node: %d %p\n", $2, $$); }
    | '^' NOTE { $$ = newNode($2, 2); printf("new node: %d %p\n", $2, $$); }
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

Node* newNode(int note, int octave) {
    Node* p;
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");
    p->note = note;
    p->octave = octave;
    p->duration = 1;
    p->ishalf = p->ishalfend = 0;
    p->next = NULL;
    return p;
}

void makeHalf(Node* head) {
    Node* p = head;
    while (p != NULL) {
        p->ishalf = 1;
        if (p->next == NULL)
            p->ishalfend = 1;
        p = p->next;
    }
}

void printStmt(Node* head) {
    Node* p = head;
    int i;
    while (p != NULL) {
        putchar(octave[p->octave][p->note]);
        for (i = 1; i < p->duration; ++i)
            putchar('-');
        if (!p->ishalf || p->ishalfend)
            putchar(' ');
        p = p->next;
    }
}

void connectNode(Node* e1, Node* e2) {
    Node* p = e1;
    if (e1 == NULL || e2 == NULL) return;
    while (p->next != NULL) p = p->next;
    p->next = e2;
}

int main(void) {
    yyparse();
    return 0;
}