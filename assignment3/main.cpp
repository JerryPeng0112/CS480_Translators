#include <iostream>
#include <deque>
#include <sstream>
#include "parser.hpp"

extern int yylex();

extern AST_node* root;

void print_arrow(std::string parent_symbol, std::string symbol);
void print_label(std::string symbol, AST_node* node);

int main() {
    std::deque<AST_node*> node_queue;
    std::deque<std::string> node_symbol;
    std::deque<std::string> node_parent_symbol;
    std::stringstream ss;
    if (!yylex()) {
        std::cout << "digraph G {" << std::endl;

        AST_node* curr;
        std::string curr_symbol;
        node_queue.push_back(root);
        node_symbol.push_back("n0");

        do {
            curr = node_queue.back();
            curr_symbol = node_symbol.back();

            if (!node_parent_symbol.empty()) {
                print_arrow(node_parent_symbol.back(), node_symbol.back());
                node_parent_symbol.pop_back();
            }

            print_label(node_symbol.back(), node_queue.back());
            node_symbol.pop_back();
            node_queue.pop_back();

            if (curr->get_left() != NULL || curr->get_right() != NULL) {
                if (curr->get_right() != NULL) {
                    node_queue.push_back(curr->get_right());
                    node_parent_symbol.push_back(curr_symbol);
                    node_symbol.push_back(curr_symbol + "_rhs");
                }
                if (curr->get_left() != NULL) {
                    node_queue.push_back(curr->get_left());
                    node_parent_symbol.push_back(curr_symbol);
                    node_symbol.push_back(curr_symbol + "_lhs");
                }
            }
            else if (!curr->get_children().empty()){
                for (int i = curr->get_children().size() - 1; i >=0; i--) {
                    node_queue.push_back(curr->get_children()[i]);
                    node_parent_symbol.push_back(curr_symbol);
                    ss.str("");
                    ss << i;
                    node_symbol.push_back(curr_symbol + "_" + ss.str());
                }
            }
        } while (!node_queue.empty());

        std::cout << "}" << std::endl;
    }
    delete root;
}

void print_arrow(std::string parent_symbol, std::string symbol) {
    std::cout << "  " << parent_symbol << " -> " << symbol << ";" << std::endl;
}

void print_label(std::string symbol, AST_node* node) {
    std::string value = node->get_name();
    if (value == "Identifier" || value == "Float" || value == "Integer" || value == "Boolean") {
        value = value + ": " + node->get_value();
        std::cout << "  " << symbol << " [shape=box,label=\"" << value << "\"];" << std::endl;
    } else {
        std::cout << "  " << symbol << " [label=\"" << value << "\"];" << std::endl;
    }
}
