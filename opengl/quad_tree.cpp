#include <iostream>
#include <cmath>

#include "quad_tree.h"

using namespace std;

// Insert a node into the quadtree
void Quad::insert(Node *node)
{
    if (node == NULL)
        return;

    // Current quad cannot contain it
    if (!inBoundary(node->pos))
        return;

    node->next = n;
    n = node;
    count++;

    // We are at a quad of unit area
    // We cannot subdivide this quad further
    if (abs(topLeft.x - botRight.x) <= MIN_QUAD_LENGTH ||
        abs(topLeft.y - botRight.y) <= MIN_QUAD_LENGTH ||
        count < MAX_NODES_IN_QUAD)
        return;

    if (topLeftTree == NULL)
    {
        topLeftTree = new Quad(
            Point(topLeft.x, topLeft.y),
            Point((topLeft.x + botRight.x) / 2, (topLeft.y + botRight.y) / 2));
        botLeftTree = new Quad(
            Point(topLeft.x, (topLeft.y + botRight.y) / 2),
            Point((topLeft.x + botRight.x) / 2, botRight.y));
        topRightTree = new Quad(
            Point((topLeft.x + botRight.x) / 2, topLeft.y),
            Point(botRight.x, (topLeft.y + botRight.y) / 2));
        botRightTree = new Quad(
            Point((topLeft.x + botRight.x) / 2, (topLeft.y + botRight.y) / 2),
            Point(botRight.x, botRight.y));
    }

    while (n != NULL) {
        topLeftTree->insert(n);
        botLeftTree->insert(n);
        topRightTree->insert(n);
        botRightTree->insert(n);
        n = n->next;
    }
}

// Find a node in a quadtree
Node* Quad::search(Point tl, Point br)
{
    // Current quad cannot contain it
    if (!overlaps(tl, br))
        return NULL;

    Node *result = NULL;
    // We are at a quad of unit length
    // We cannot subdivide this quad further
    if (abs(topLeft.x - botRight.x) <= MIN_QUAD_LENGTH ||
        abs(topLeft.y - botRight.y) <= MIN_QUAD_LENGTH ||
        count < MAX_NODES_IN_QUAD)
    {
        Node *curr = n;
        while (curr != NULL)
        {
            if (curr->pos.x >= tl.x &&
                    curr->pos.x <= br.x &&
                    curr->pos.y >= tl.y &&
                    curr->pos.y <= br.y)
            {
                Node *node = (Node *)malloc(sizeof(struct Node));
                node->pos = curr->pos;
                node->next = result;
                result = node;
            }
            curr = curr->next;
        }

        return result;
    }

    Node *head = topLeftTree->search(tl, br);
    if (head != NULL)
    {
        Node *curr = head;
        while (curr->next != NULL)
            curr = curr->next;

        curr->next = result;
        result = head;
    }

    head = topRightTree->search(tl, br);
    if (head != NULL)
    {
        Node *curr = head;
        while (curr->next != NULL)
            curr = curr->next;

        curr->next = result;
        result = head;
    }

    head = botLeftTree->search(tl, br);
    if (head != NULL)
    {
        Node *curr = head;
        while (curr->next != NULL)
            curr = curr->next;

        curr->next = result;
        result = head;
    }

    head = botRightTree->search(tl, br);
    if (head != NULL)
    {
        Node *curr = head;
        while (curr->next != NULL)
            curr = curr->next;

        curr->next = result;
        result = head;
    }

    return result;
}

// Check if current quadtree contains the point
bool Quad::inBoundary(Point p)
{
    return (p.x >= topLeft.x &&
        p.x <= botRight.x &&
        p.y >= topLeft.y &&
        p.y <= botRight.y);
}

bool Quad::overlaps(Point tl, Point br)
{
    if (topLeft.x > br.x || tl.x > botRight.x)
        return false;

    if (topLeft.y > br.y || tl.y > botRight.y)
        return false;

    return true;
}

