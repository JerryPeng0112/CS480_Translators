%{
#include <iostream>
#include <vector>

#include "parser.hpp"

/* The root of the AST */
AST_node* root;

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
%}

/* require code to import classes */
%code requires{
	#include "AST_node.hpp"
}

/* Enable location tracking. */
%locations

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */

%union{
    int token;
    std::string* str;
    AST_node* node;
}

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */

%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */

%token <str> IDENTIFIER
%token <str> FLOAT INTEGER BOOLEAN
%token <token> INDENT DEDENT NEWLINE
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <token>ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> EQ NEQ GT GTE LT LTE
%token <token> LPAREN RPAREN COMMA COLON

/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */

%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/* type definition */
%type <node> program statements statement primary_expression negated_expression expression assign_statement block condition if_statement elif_blocks else_block while_statement break_statement

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */
program
    : statements { root = new AST_node("Block", "", $1); }
    ;

statements
    : statement
        {
            AST_node* temp = new AST_node("", "");
            temp->add_child($1);
            $$ = temp;
        }
    | statements statement
        {
            AST_node* temp = new AST_node("", "", $1);
            temp->add_child($2);
            $$ = temp;
        }
    ;

statement
    : assign_statement { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | break_statement { $$ = $1; }
    ;

primary_expression
    : IDENTIFIER { $$ = new AST_node("Identifier", *$1); delete $1; }
    | FLOAT { $$ = new AST_node("Float", *$1); delete $1; }
    | INTEGER { $$ = new AST_node("Integer", *$1); delete $1; }
    | BOOLEAN
        {
            if (*$1 == "True")
                $$ = new AST_node("Boolean", "1");
            if (*$1 == "False")
                $$ = new AST_node("Boolean", "0");
            delete $1;
        }
    | LPAREN expression RPAREN { $$ = $2;}
    ;

negated_expression
    : NOT primary_expression { $$ = new AST_node("NOT", "", NULL, $2); }
    ;

expression
    : primary_expression { $$ = $1; }
    | negated_expression { $$ = $1; }
    | expression PLUS expression { $$ = new AST_node("PLUS", "", $1, $3); }
    | expression MINUS expression { $$ = new AST_node("MINUS", "", $1, $3); }
    | expression TIMES expression { $$ = new AST_node("TIMES", "", $1, $3); }
    | expression DIVIDEDBY expression { $$ = new AST_node("DIVIDEDBY", "", $1, $3); }
    | expression EQ expression { $$ = new AST_node("EQ", "", $1, $3); }
    | expression NEQ expression { $$ = new AST_node("NEQ", "", $1, $3); }
    | expression GT expression { $$ = new AST_node("GT", "", $1, $3); }
    | expression GTE expression { $$ = new AST_node("GTE", "", $1, $3); }
    | expression LT expression { $$ = new AST_node("LT", "", $1, $3); }
    | expression LTE expression { $$ = new AST_node("LTE", "", $1, $3); }
    ;

assign_statement
    : IDENTIFIER ASSIGN expression NEWLINE
        {
            AST_node* identifier = new AST_node("Identifier", *$1);
            delete $1;
            $$ = new AST_node("Assignment", "", identifier, $3);
        }
    ;

block
    : INDENT statements DEDENT { $$ = new AST_node("Block", "" , $2); }
    ;

condition
    : expression { $$ = $1; }
    | condition AND condition { $$ = new AST_node("AND", "", $1, $3); }
    | condition OR condition { $$ = new AST_node("OR", "", $1, $3); }
    ;

if_statement
    : IF condition COLON NEWLINE block elif_blocks else_block
        {
            AST_node* if_node = new AST_node("If", "");
            if_node->add_child($2);
            if_node->add_child($5);
            if ($6 != NULL) {
                if_node->add_child($6);
            }
            if ($7 != NULL) {
                if_node->add_child($7);
            }
            $$ = if_node;
        }
    ;

elif_blocks
    : %empty { $$ = NULL; }
    | elif_blocks ELIF condition COLON NEWLINE block
        {
            if ($1 == NULL) {
                AST_node* elif_node = new AST_node("Elif", "");
                elif_node->add_child($3);
                elif_node->add_child($6);
                $$ = elif_node;
            } else {
                AST_node* elif_node = new AST_node("Elif", "", $1);
                elif_node->add_child($3);
                elif_node->add_child($6);
                $$ = elif_node;
            }
        }
    ;

else_block
    : %empty { $$ = NULL; }
    | ELSE COLON NEWLINE block { $$ = $4; }


while_statement
    : WHILE condition COLON NEWLINE block { $$ = new AST_node("While", "", $2, $5); }
    ;

break_statement
    : BREAK NEWLINE { $$ = new AST_node("BREAK", "", NULL, NULL);}
    ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
    std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
