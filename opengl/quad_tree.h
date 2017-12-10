#include <vector>

#define MAX_NODES_IN_QUAD 10
#define MIN_QUAD_LENGTH 10

// Used to hold details of a point
struct Point
{
    float x;
    float y;
    float w;
    Point(float _x, float _y)
    {
        x = _x;
        y = _y;
        w = 1.0f;
    }
    Point(float _x, float _y, float _w)
    {
        x = _x;
        y = _y;
        w = _w;
    }
    Point()
    {
        x = 1.0f;
        y = 1.0f;
    }
};

// The objects that we want stored in the quadtree
// The main quadtree class
class Quad
{
    // Hold details of the boundary of this node
    Point topLeft;
    Point botRight;

    std::vector<Point> points;

    // Children of this tree
    Quad *topLeftTree;
    Quad *topRightTree;
    Quad *botLeftTree;
    Quad *botRightTree;

public:
    Quad()
    {
        topLeft = Point();
        botRight = Point();
        topLeftTree  = NULL;
        topRightTree = NULL;
        botLeftTree  = NULL;
        botRightTree = NULL;
    }
    Quad(Point topL, Point botR)
    {
        topLeft = topL;
        botRight = botR;
        topLeftTree  = NULL;
        topRightTree = NULL;
        botLeftTree  = NULL;
        botRightTree = NULL;
    }
    void insert(Point&);
    void search(Point&, Point&, float, float);
    bool inBoundary(Point&);
    bool overlaps(Point&, Point&);
};
