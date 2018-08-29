%{
    #include <iostream>
    #include <map>
    #include <sstream>
    #include "parser.hpp"

    std::map<std::string, float> symbols;
    std::string* program;
    std::stringstream ss;
    void yyerror(YYLTYPE* loc, const char* err);
    extern int yylex();
%}

%union {
    float value;
    std::string* str;
    int token;
}

%locations
%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER
%token <value> DOUBLE
%token <token> INDENT DEDENT NEWLINE TRUE FALSE
%token <token> IF ELIF ELSE
%token <token> WHILE BREAK
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY EQ NEQ GT GTE LT LTE NOT LPAREN RPAREN COLON
%token <token> AND DEF FOR OR RETURN COMMA

%type <str> program statements statement assignment_statement jump_statement if_statement elif_statements elif_statement while_statement expression

%left PLUS MINUS
%left TIMES DIVIDEDBY

%start program

%%

program
    : statements { program = $1; }

statements
    : statements statement { $$ = new std::string(*$1 + *$2); }
    | statement { $$ = $1; }
    ;

statement
    : assignment_statement { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | jump_statement { $$ = $1; }
    ;

assignment_statement
    : IDENTIFIER ASSIGN expression NEWLINE { $$ = new std::string(*$1 + " = " + *$3 + ";\n"); symbols[*$1] = 0; delete $1;}
    ;

jump_statement
    : BREAK NEWLINE { $$ = new std::string("break;\n"); }
    ;

if_statement
    : IF expression COLON NEWLINE INDENT statements DEDENT
        elif_statements
        ELSE COLON NEWLINE INDENT statements DEDENT
        {
            $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "} " + *$8 + "else {\n" + *$13 + "}\n");
        }
    | IF expression COLON NEWLINE INDENT statements DEDENT
        elif_statements
        {
            $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "} " + *$8 + "\n");
        }

    | IF expression COLON NEWLINE INDENT statements DEDENT
        ELSE COLON NEWLINE INDENT statements DEDENT
        {
            $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "} else {\n" + *$12 + "}\n");
        }

    | IF expression COLON NEWLINE INDENT statements DEDENT
        {
            $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + "}\n");
        }
    ;

elif_statements
    : elif_statements elif_statement { $$ = new std::string(*$1 + *$2); }
    | elif_statement { $$ = $1; }
    ;

elif_statement
    : ELIF expression COLON NEWLINE INDENT statements DEDENT
        {
            $$ = new std::string("else if (" + *$2 + ") {" + *$6 + "} ");
        }
    ;

while_statement
    : WHILE expression COLON NEWLINE INDENT statements DEDENT
        {
            $$ = new std::string("while (" + *$2 + ") {\n" + *$6 + "}\n");
        }
    ;

expression
    : LPAREN expression RPAREN { $$ = new std::string("(" + *$2 + ")"); }
    | expression PLUS expression { $$ = new std::string(*$1 + " + " + *$3); }
    | expression MINUS expression { $$ = new std::string(*$1 + " - " + *$3); }
    | expression TIMES expression { $$ = new std::string(*$1 + " * " + *$3); }
    | expression DIVIDEDBY expression { $$ = new std::string(*$1 + " / " + *$3); }
    | expression EQ expression { $$ = new std::string(*$1 + " == " + *$3); }
    | expression NEQ expression { $$ = new std::string(*$1 + " != " + *$3); }
    | expression GT expression  { $$ = new std::string(*$1 + " > " + *$3); }
    | expression GTE expression { $$ = new std::string(*$1 + " >= " + *$3); }
    | expression LT expression { $$ = new std::string(*$1 + " < " + *$3); }
    | expression LTE expression { $$ = new std::string(*$1 + " <= " + *$3); }
    | NOT expression { $$ = new std::string("!" + *$2);  }
    | TRUE { $$ = new std::string("true"); }
    | FALSE { $$ = new std::string("false"); }
    | DOUBLE
        {
            ss.str("");
            ss << $1;
            $$ = new std::string(ss.str());
        }
    | IDENTIFIER { $$ = new std::string(*$1); symbols[*$1] = 0; delete $1; }
    ;

%%
void yyerror(YYLTYPE* loc, const char* err) {
    std::cerr << "Error: " << err << std::endl;
}
