#include "AST_node.hpp"

AST_node::AST_node(std::string name, std::string value) {
    this->name = name;
    this->value = value;
    this->right = NULL;
    this->left = NULL;
}
AST_node::AST_node(std::string name, std::string value, AST_node* child_node) {
    this->name = name;
    this->value = value;
    this->children = child_node->children;
    this->left = NULL;
    this->right = NULL;
    delete child_node;
}

AST_node::AST_node(std::string name, std::string value, AST_node* left, AST_node* right) {
    this->name = name;
    this->value = value;
    this->left = left;
    this->right = right;
}

void AST_node::add_child(AST_node* child) {
    this->children.push_back(child);
}

void AST_node::add_children(AST_node* temp) {
    this->children.insert(this->children.end(), temp->children.begin(), temp->children.end());
}

std::vector<AST_node*> AST_node::get_children() {
    return children;
}

std::string AST_node::get_name() {
    return name;
}

std::string AST_node::get_value() {
    return value;
}

AST_node* AST_node::get_left() {
    return left;
}

AST_node* AST_node::get_right() {
    return right;
}

AST_node::~AST_node() {}
