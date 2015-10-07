%{
#include <stdlib.h>
#include "piano.tab.h"
//#include "node.h"

void yyerror(char *);
%}
%%
  /* notes */
[drmfslt] {
  switch (*yytext) {
    case 'd': yylval.iVal = 0; break;
    case 'r': yylval.iVal = 1; break;
    case 'm': yylval.iVal = 2; break;
    case 'f': yylval.iVal = 3; break;
    case 's': yylval.iVal = 4; break;
    case 'l': yylval.iVal = 5; break;
    case 't': yylval.iVal = 6; break;
  }
  return NOTE;
}

  /* integers */
[0-9]+ { yylval.iVal = atoi(yytext); return INTEGER; }

  /* variables */
[A-Z] { yylval.iVal = *yytext - 'A'; return VARIABLE; }

  /* operators */
[\[\]()\-_^\n] { return *yytext; }

  /* skip whitespace */
[ \t] ;

  /* anything else is an error */
. yyerror("invalid character");
