#include <iostream>
#include <map>

extern int yylex();

extern std::map<std::string, float> symbols;
extern std::string* program;

void generateProgram();

int main(int argc, char const *argv[]) {
    if (!yylex()) {
        generateProgram();
        return 0;
    } else {
        return 1;
    }
}

void generateProgram() {
    std::map<std::string, float>::iterator it;

    std::cout   << "#include <iostream>" << std::endl
                << "int main() {" << std::endl;

    for (it = symbols.begin(); it != symbols.end(); it++) {
        std::cout << "double " << it->first << ";" << std::endl;
    }

    std::cout << std::endl << "/* Begin Program */" << std::endl << std::endl;

    std::cout << *program << std::endl;

    std::cout << "/* End Program */" << std::endl << std::endl;

    for (it = symbols.begin(); it != symbols.end(); it++) {
        std::cout << "std::cout << \"" << it->first << ": \" << " << it->first << " << std::endl;" << std::endl;
    }

    std::cout << "}" << std::endl;
}
