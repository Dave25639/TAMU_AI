# search.py
# ---------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
#
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).

"""
In search.py, you will implement generic search algorithms which are called by
Pacman agents (in search_agents.py).
"""

from builtins import object
import util

def tiny_maze_search(problem):
    """
    Returns a sequence of moves that solves tiny_maze.  For any other maze, the
    sequence of moves will be incorrect, so only use this for tiny_maze.
    """
    from game import Directions

    s = Directions.SOUTH
    w = Directions.WEST
    return [s, s, w, s, w, w, s, w]


def depth_first_search(problem):
    """Search the deepest nodes in the search tree first."""
    start_state = problem.get_start_state()

    stack = [(start_state, [])]
    visited = set()

    while stack:
        current_node, path = stack.pop()

        if problem.is_goal_state(current_node):
            return path

        if current_node not in visited:
            visited.add(current_node)

            transitions = problem.get_successors(current_node)
            for t in transitions:
                if t.state not in visited:
                    stack.append((t[0], path + [t.action]))

    return []
    util.raise_not_defined()


def breadth_first_search(problem):
    """Search the shallowest nodes in the search tree first."""
    start_state = problem.get_start_state()

    queue = [(start_state, [])]
    visited = set()

    while queue:
        current_node, path = queue.pop(0)

        if problem.is_goal_state(current_node):
            return path

        if current_node not in visited:
            visited.add(current_node)
            transitions = problem.get_successors(current_node)
            for t in transitions:
                if t.state not in visited:
                    queue.append((t.state, path + [t.action]))

    return []
    util.raise_not_defined()


def uniform_cost_search(problem, heuristic=None):
    """Search the node of least total cost first."""
    pq = util.PriorityQueue()
    start_state = problem.get_start_state()
    pq.push((start_state, 0, []), 0)
    visited = set()

    while(pq):
        currState, costSoFar, path = pq.pop()

        if problem.is_goal_state(currState):
            return path

        if currState not in visited:
            visited.add(currState)
            transitions = problem.get_successors(currState)
            for t in transitions:
                if t.state not in visited:
                    newCost = costSoFar + t.cost
                    pq.push((t.state, newCost, path + [t.action]), newCost)

    return []
    util.raise_not_defined()


def null_heuristic(state, problem=None):
    """
    A heuristic function estimates the cost from the current state to the nearest
    goal in the provided SearchProblem.  This heuristic is trivial.
    """
    return 0


def a_star_search(problem, heuristic=null_heuristic):
    """Search the node that has the lowest combined cost and heuristic first."""
    pq = util.PriorityQueue()
    start_state = problem.get_start_state()
    pq.push((start_state, 0, []), 0)
    visited = set()

    while(pq):
        currState, costSoFar, path = pq.pop()

        if problem.is_goal_state(currState):
            return path

        if currState not in visited:
            visited.add(currState)
            transitions = problem.get_successors(currState)
            for t in transitions:
                if t.state not in visited:
                    newCost = costSoFar + t.cost
                    pq.push((t.state, newCost, path + [t.action]), newCost + heuristic(t.state, problem))

    return []
    util.raise_not_defined()

# (you can ignore this, although it might be helpful to know about)
# This is effectively an abstract class
# it should give you an idea of what methods will be available on problem-objects
class SearchProblem(object):
    """
    This class outlines the structure of a search problem, but doesn't implement
    any of the methods (in object-oriented terminology: an abstract class).

    You do not need to change anything in this class, ever.
    """

    def get_start_state(self):
        """
        Returns the start state for the search problem.
        """
        util.raise_not_defined()

    def is_goal_state(self, state):
        """
          state: Search state

        Returns True if and only if the state is a valid goal state.
        """
        util.raise_not_defined()

    def get_successors(self, state):
        """
          state: Search state

        For a given state, this should return a list of triples, (successor,
        action, step_cost), where 'successor' is a successor to the current
        state, 'action' is the action required to get there, and 'step_cost' is
        the incremental cost of expanding to that successor.
        """
        util.raise_not_defined()

    def get_cost_of_actions(self, actions):
        """
         actions: A list of actions to take

        This method returns the total cost of a particular sequence of actions.
        The sequence must be composed of legal moves.
        """
        util.raise_not_defined()


# fallback on a_star_search
for function in [breadth_first_search, depth_first_search, uniform_cost_search, ]:
    try: function(None)
    except util.NotDefined as error: exec(f"{function.__name__} = a_star_search", globals(), globals())
    except: pass


# Abbreviations
bfs   = breadth_first_search
dfs   = depth_first_search
astar = a_star_search
ucs   = uniform_cost_search