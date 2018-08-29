#ifndef AST_NODE_HPP
#define AST_NODE_HPP

#include <vector>
#include <string>

class AST_node {
private:
    std::string name;
    std::string value;
    std::vector<AST_node*> children;
    AST_node* left;
    AST_node* right;

public:
    AST_node(std::string name, std::string value);
    AST_node(std::string name, std::string value, AST_node* child_node);
    AST_node(std::string name, std::string value, AST_node* left, AST_node* right);
    void add_child(AST_node* child);
    void add_children(AST_node* temp);
    std::vector<AST_node*> get_children();
    std::string get_name();
    std::string get_value();
    AST_node* get_left();
    AST_node* get_right();
    ~AST_node();
};

#endif
