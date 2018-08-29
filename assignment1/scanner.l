%{
    #include <iostream>
    #include <vector>
    #include <string>
    using namespace std;

    // Counts of indentation on previous line
    int prev_indent_count = 0;

    // Counts of indentation on current line
    int curr_indent_count = 0;

    // Variable to keep track of tab length
    int tab_length = 0;

    // Data structure of a word
    struct Word {
        string category;
        string lexeme;
    };

    // Array of to hold words
    vector<Word> words;

    // Function to save lexeme and category to words
    void save_word (string category, string lexeme) {
        Word word = {
            category,
            lexeme,
        };
        words.push_back(word);
    }
%}

DIGIT   [0-9]
ALPHA   [a-zA-Z]

%option noyywrap

%%

#.*\n
"and" { save_word("AND", yytext); }
"break" { save_word("BREAK", yytext); }
"def" { save_word("DEF", yytext); }
"elif" { save_word("ELIF", yytext); }
"else" { save_word("ELSE", yytext); }
"for" { save_word("FOR", yytext); }
"if" { save_word("IF", yytext); }
"not" { save_word("NOT", yytext); }
"or" { save_word("OR", yytext); }
"return" { save_word("RETURN", yytext); }
"while" { save_word("WHILE", yytext); }
"=" { save_word("ASSIGN", yytext); }
"+" { save_word("PLUS", yytext); }
"-" { save_word("MINUS", yytext); }
"*" { save_word("TIMES", yytext); }
"/" { save_word("DIVIDEDBY", yytext); }
"==" { save_word("EQ", yytext); }
"!=" { save_word("NEQ", yytext); }
">" { save_word("GT", yytext); }
">=" { save_word("GTE", yytext); }
"<" { save_word("LT", yytext); }
"<=" { save_word("LTE", yytext); }
"(" { save_word("LPAREN", yytext); }
")" { save_word("RPAREN", yytext); }
"," { save_word("COMMA", yytext); }
":" { save_word("COLON", yytext); }
"\n" { save_word("NEWLINE", ""); }

-?{DIGIT}+\.{DIGIT}* {
    save_word("FLOAT", yytext);
}

-?{DIGIT}+ {
    save_word("INTEGER", yytext);
}

True|False {
    save_word("BOOLEAN", yytext);
}

(-|{ALPHA})(-|{ALPHA}|{DIGIT})* {
    save_word("IDENTIFIER", yytext);
}

.

%%

int main() {
    yylex();
    vector<Word>::iterator words_iter;
    string category;
    for (words_iter = words.begin(); words_iter != words.end(); ++words_iter) {
        cout << words_iter->category << "\t\t" << words_iter->lexeme << endl;
    }
}
