#include <iostream>
#include <cmath>

#include "gl_utility.h"

using namespace std;

// Insert a node into the quadtree
void Quad::insert(Point& point)
{
    // Current quad cannot contain it
    if (!inBoundary(point))
        return;

    points.push_back(point);

    // We are at a quad of unit area
    // We cannot subdivide this quad further
    if (abs(topLeft.x - botRight.x) <= MIN_QUAD_LENGTH ||
        abs(topLeft.y - botRight.y) <= MIN_QUAD_LENGTH ||
        (topLeftTree == NULL && points.size() < MAX_NODES_IN_QUAD))
    {
        return;
    }

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

    while (!points.empty()) {
        Point p = points.back();
        topLeftTree->insert(p);
        topRightTree->insert(p);
        botLeftTree->insert(p);
        botRightTree->insert(p);
        points.pop_back();
    }
}

// Find a node in a quadtree
void Quad::search(Point& tl, Point& br, float x_gap, float y_gap)
{
    // Current quad cannot contain it
    if (!overlaps(tl, br))
        return;

    // We are at a quad of unit length
    // We cannot subdivide this quad further
    if (abs(topLeft.x - botRight.x) <= MIN_QUAD_LENGTH ||
        abs(topLeft.y - botRight.y) <= MIN_QUAD_LENGTH ||
        topLeftTree == NULL)
    {
        for (Point p: points)
        {
            if (p.x >= tl.x && p.y >= tl.y && p.x < br.x && p.y < br.y) {
                unsigned x = (unsigned)floor((p.x - tl.x) / x_gap);
                unsigned y = (unsigned)floor((p.y - tl.y) / y_gap);
                heatmap_add_point(hm, x, y);
            }
        }

        return;
    }

    topLeftTree->search(tl, br, x_gap, y_gap);
    topRightTree->search(tl, br, x_gap, y_gap);
    botLeftTree->search(tl, br, x_gap, y_gap);
    botRightTree->search(tl, br, x_gap, y_gap);
}

// Check if current quadtree contains the point
bool Quad::inBoundary(Point& p)
{
    return (p.x >= topLeft.x &&
        p.x < botRight.x &&
        p.y >= topLeft.y &&
        p.y < botRight.y);
}

bool Quad::overlaps(Point& tl, Point& br)
{
    if (topLeft.x > br.x || tl.x > botRight.x)
        return false;

    if (topLeft.y > br.y || tl.y > botRight.y)
        return false;

    return true;
}

