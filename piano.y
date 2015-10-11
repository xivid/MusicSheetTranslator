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
Node* makeCopy(Node* p);
Node* makeHalf(Node* head);
Node* genRepetition(Node* head, int rep);
void printStmt(Node* head);
void connectNode(Node* e1, Node* e2);
void changeOctave(Node* head, int d);
void addDuration(Node* head, int d);

const char octave[][8] = {"890qwer", "tyuiopa", "sdfghjk"};
Node* sym[26];
%}

%union {
    int iVal;
    struct node* pNode;
};

%token <iVal> NOTE VARIABLE INTEGER END

%type <pNode> stmt expr note song

%%
song:
    song stmt END {
            if ($1 == NULL) $$ = $2; else {$$ = $1; connectNode($1, $2);} 
            printStmt($$); 
            return 0; 
        }
    | song stmt { if ($1 == NULL) $$ = $2; else {$$ = $1; connectNode($1, $2);} }
    | {$$ = NULL; }
    ;

stmt:
    expr stmt { if ($1 == NULL) $$ = $2; else {$$ = $1; connectNode($1, $2); } }
    | '^' '(' song ')' { $$ = $3; changeOctave($3, +1); }
    | '_' '(' song ')' { $$ = $3; changeOctave($3, -1); }
    | '[' stmt ']' { $$ = makeHalf($2); }
    | {$$ = NULL; }
    ;

expr:
    note expr { $$ = $1; $1->next = $2; }
    | note '-' { $$ = $1; $1->duration = 2; }
    | note '-' '-' { $$ = $1; $1->duration = 3; }
    | note '-' '-' '-' { $$ = $1; $1->duration = 4; }
    | '(' expr ')' '-' { $$ = $2; addDuration($2, 1); }
    | '(' expr ')' '-' '-' { $$ = $2; addDuration($2, 2); }
    | '(' expr ')' '-' '-' '-' { $$ = $2; addDuration($2, 3); }
    | VARIABLE '=' song ';' { sym[$1] = $3; $$ = NULL; }
    | '$' VARIABLE { $$ = makeCopy(sym[$2]); }
    | INTEGER '{' song '}' { $$ = genRepetition($3, $1); }
    | { $$ = NULL; } 
    ;

note:
    NOTE { $$ = newNode($1, 1); }
    | '_' NOTE { $$ = newNode($2, 0); }
    | '^' NOTE { $$ = newNode($2, 2); }
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

Node* makeCopy(Node* p) {
    Node *q = NULL, *ret = NULL;
    if (p != NULL) {
        // the first node, of which the pointer to be returned
        if ((q = ret = (Node*)malloc(sizeof(Node))) == NULL)
            yyerror("out of memory");
        memcpy(q, p, sizeof(Node));
        q->next = NULL;
        p = p->next;
    }
    while (p != NULL) {
        if ((q->next = (Node*)malloc(sizeof(Node))) == NULL)
            yyerror("out of memory");
        q = q->next;
        memcpy(q, p, sizeof(Node));
        q->next = NULL;
        p = p->next;
    }
    return ret;
}

Node* makeHalf(Node* head) {
    Node* p = head;
    while (p != NULL) {
        p->ishalf = 1;
        if (p->next == NULL)
            p->ishalfend = 1;
        p = p->next;
    }
    return head;
}

Node* genRepetition(Node* head, int rep) {
    int i;
    Node *single = head, *p, *another;
    if (head == NULL) return NULL;
    for (i = 1; i < rep; ++i) {
        // first node
        if ((p = (Node*)malloc(sizeof(Node))) == NULL)
            yyerror("out of memory");
        another = p; // head of the new single part
        memcpy(p, single, sizeof(Node));
        p->next = NULL;
        single = single->next;

        while (1) {
            if ((p->next = (Node*)malloc(sizeof(Node))) == NULL)
                yyerror("out of memory");
            p = p->next;
            memcpy(p, single, sizeof(Node));
            p->next = NULL;
            if (single->next == NULL) {
                single->next = another; // connect with the new part
                single = another; // switch to another single part
                break;
            }
            single = single->next;
        }
    }
    return head;
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

void changeOctave(Node* head, int d) {
    Node* p = head;
    while (p != NULL) {
        p->octave += d;
        p = p->next;
    }
}

void addDuration(Node* head, int d) {
    Node* p = head;
    while (p != NULL) {
        p->duration += d;
        p = p->next;
    }
}

int main(void) {
    yyparse();
    return 0;
}