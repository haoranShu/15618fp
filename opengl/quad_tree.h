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
        x = 0;
        y = 0;
    }
};

// The objects that we want stored in the quadtree
struct Node
{
    Point pos;
    Node *next;

    Node(Point _pos)
    {
        pos = _pos;
        next = NULL;
    }
};

// The main quadtree class
class Quad
{
    // Hold details of the boundary of this node
    Point topLeft;
    Point botRight;

    size_t count;
    // Contains details of node
    Node *n;

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
        n = NULL;
        count = 0;
        topLeftTree  = NULL;
        topRightTree = NULL;
        botLeftTree  = NULL;
        botRightTree = NULL;
    }
    Quad(Point topL, Point botR)
    {
        n = NULL;
        count = 0;
        topLeftTree  = NULL;
        topRightTree = NULL;
        botLeftTree  = NULL;
        botRightTree = NULL;
        topLeft = topL;
        botRight = botR;
    }
    void insert(Node*);
    Node* search(Point, Point);
    bool inBoundary(Point);
    bool overlaps(Point, Point);
};
