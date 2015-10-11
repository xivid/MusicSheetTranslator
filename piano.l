%{
#include <stdlib.h>
#include "piano.tab.h"

void yyerror(char *);
%}

space     [ \t]
integer   [0-9]+
octave    [drmfslt]
variable  [A-Z]
operator  [\n\[\](){}\-_^=;$]
comment   #.*\n

%%
  /* notes */
{octave} {
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
{integer} { yylval.iVal = atoi(yytext); return INTEGER; }

  /* variables */
{variable} { yylval.iVal = *yytext - 'A'; return VARIABLE; }

  /* operators (maybe we can deal with \n and comments here) */
{operator} { return *yytext; }

  /* skip whitespace */
{space} ;

  /* end of input */
<<EOF>> { return END; }

{comment} ;
  /* anything else is an error */
. yyerror(yytext);
