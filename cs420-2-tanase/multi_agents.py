from __future__ import print_function

# multi_agents.py
# --------------
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
import sys
from builtins import range
from util import manhattan_distance
from game import Directions
import random, util

from game import Agent

class ReflexAgent(Agent):
    """
      A reflex agent chooses an action at each choice point by examining
      its alternatives via a state evaluation function.

      The code below is provided as a guide.  You are welcome to change
      it in any way you see fit, so long as you don't touch our method
      headers.
    """


    def get_action(self, game_state):
        """
        You do not need to change this method, but you're welcome to.

        get_action chooses among the best options according to the evaluation function.

        Just like in the previous project, get_action takes a GameState and returns
        some Directions.X for some X in the set {North, South, West, East, Stop}
        """
        # Collect legal moves and successor states
        legal_moves = game_state.get_legal_actions()

        # Choose one of the best actions
        scores = [self.evaluation_function(game_state, action) for action in legal_moves]
        best_score = max(scores)
        best_indices = [index for index in range(len(scores)) if scores[index] == best_score]
        chosen_index = random.choice(best_indices) # Pick randomly among the best

        "Add more of your code here if you want to"

        return legal_moves[chosen_index]

    def evaluation_function(self, current_game_state, action):
        """
        Design a better evaluation function here.

        The evaluation function takes in the current and proposed successor
        GameStates (pacman.py) and returns a number, where higher numbers are better.

        The code below extracts some useful information from the state, like the
        remaining food (new_food) and Pacman position after moving (new_pos).
        new_scared_times holds the number of moves that each ghost will remain
        scared because of Pacman having eaten a power pellet.

        Print out these variables to see what you're getting, then combine them
        to create a masterful evaluation function.
        """
        # Useful information you can extract from a GameState (pacman.py)
        successor_game_state = current_game_state.generate_pacman_successor(action)
        new_pos = successor_game_state.get_pacman_position()
        new_food = successor_game_state.get_food()
        new_ghost_states = successor_game_state.get_ghost_states()
        new_scared_times = [ghost_state.scared_timer for ghost_state in new_ghost_states]

        #print("new_pos: ", new_pos)
        #print("new_food: ", new_food)
        #print("new_ghost_states", new_ghost_states[0])

        newX, newY = new_pos
        cost = 0

        ghost_distances = [manhattan_distance(new_pos, ghost_state.get_position()) for ghost_state in new_ghost_states]
        food_distances = [manhattan_distance(new_pos, food_pos) for food_pos in new_food.as_list()]

        food_score = 0
        ghost_score = 0
        if len(food_distances) > 0:
            food_score = 1.0 / (1.5 + min(food_distances)) # 5*(1-0.8)**min(food_distances)

        if min(ghost_distances) < 7:
            ghost_score = -1.03**(1.3*sum(ghost_distances))

        if min(ghost_distances) < 2:
            ghost_score = -10000

        if new_ghost_states[0].scared_timer > 0:
            ghost_score = 10000

        cost = food_score + ghost_score
        return successor_game_state.get_score() + cost

def score_evaluation_function(current_game_state):
    """
      This default evaluation function just returns the score of the state.
      The score is the same one displayed in the Pacman GUI.

      This evaluation function is meant for use with adversarial search agents
      (not reflex agents).
    """
    return current_game_state.get_score()

class MultiAgentSearchAgent(Agent):
    """
      This class provides some common elements to all of your
      multi-agent searchers.  Any methods defined here will be available
      to the MinimaxPacmanAgent, AlphaBetaPacmanAgent & ExpectimaxPacmanAgent.

      You *do not* need to make any changes here, but you can if you want to
      add functionality to all your adversarial search agents.  Please do not
      remove anything, however.

      Note: this is an abstract class: one that should not be instantiated.  It's
      only partially specified, and designed to be extended.  Agent (game.py)
      is another abstract class.
    """

    def __init__(self, eval_fn = 'score_evaluation_function', depth = '2'):
        self.index = 0 # Pacman is always agent index 0
        self.evaluation_function = util.lookup(eval_fn, globals())
        self.depth = int(depth)

class MinimaxAgent(MultiAgentSearchAgent):
    """
      Your minimax agent (question 2)
    """
    def get_action(self, game_state):
        """
          Returns the minimax action from the current game_state using self.depth
          and self.evaluation_function.

          Here are some method calls that might be useful when implementing minimax.

          game_state.get_legal_actions(agent_index):
            Returns a list of legal actions for an agent
            agent_index=0 means Pacman, ghosts are >= 1

          game_state.generate_successor(agent_index, action):
            Returns the successor game state after an agent takes an action

          game_state.get_num_agents():
            Returns the total number of agents in the game
        """
        def minimax(curr_state, d, curr_player):
            if curr_player == 0:
                best_score = -sys.maxsize
                next_depth = d+1
            else:
                best_score = sys.maxsize
                next_depth = d

            if next_depth == self.depth or curr_state.is_win() or curr_state.is_lose():
                return self.evaluation_function(curr_state), None

            best_action = None
            next_player = (curr_player+1) % game_state.get_num_agents()

            for action in curr_state.get_legal_actions(curr_player):
                next_state = curr_state.generate_successor(curr_player, action)
                curr_point_value, ignore = minimax(next_state, next_depth, next_player)

                if curr_player == 0:
                    if curr_point_value > best_score:
                        best_score = curr_point_value
                        best_action = action
                else:
                    if curr_point_value < best_score:
                        best_score = curr_point_value
                        best_action = action

            return best_score, best_action

        score, action = minimax(game_state, -1, self.index)
        return action

        util.raise_not_defined()

class AlphaBetaAgent(MultiAgentSearchAgent):
    """
      Your minimax agent with alpha-beta pruning (question 3)
    """

    def get_action(self, game_state):
        """
          Returns the minimax action using self.depth and self.evaluation_function
        """

        def alpha_beta(curr_state, d, alpha, beta, curr_player):
            if curr_player == 0:
                best_score = -sys.maxsize
                next_depth = d+1
            else:
                best_score = sys.maxsize
                next_depth = d

            if next_depth == self.depth or curr_state.is_win() or curr_state.is_lose():
                return self.evaluation_function(curr_state), None

            best_action = None
            next_player = (curr_player+1) % game_state.get_num_agents()

            for action in curr_state.get_legal_actions(curr_player):
                next_state = curr_state.generate_successor(curr_player, action)
                curr_point_value, ignore = alpha_beta(next_state, next_depth, alpha, beta, next_player)

                if curr_player == 0:
                    if curr_point_value > best_score:
                        best_score = curr_point_value
                        best_action = action
                else:
                    if curr_point_value < best_score:
                        best_score = curr_point_value
                        best_action = action

                if curr_player == 0:
                    alpha = max(alpha, best_score)
                    if best_score > beta:
                        return best_score, best_action
                else:
                    beta = min(beta, best_score)
                    if best_score < alpha:
                        return best_score, best_action

            return best_score, best_action

        score, action = alpha_beta(game_state, -1, -sys.maxsize, sys.maxsize, 0)
        return action
        util.raise_not_defined()

class ExpectimaxAgent(MultiAgentSearchAgent):
    """
      Your expectimax agent (question 4)
    """

    def get_action(self, game_state):
        def expectimax(curr_state, d, curr_player):
            if curr_player == 0:
                best_score = -sys.maxsize
                next_depth = d + 1
            else:
                best_score = 0
                next_depth = d

            if next_depth == self.depth or curr_state.is_win() or curr_state.is_lose():
                return self.evaluation_function(curr_state), None

            best_action = None
            next_player = (curr_player + 1) % game_state.get_num_agents()

            for action in curr_state.get_legal_actions(curr_player):
                next_state = curr_state.generate_successor(curr_player, action)
                curr_point_value, ignore = expectimax(next_state, next_depth, next_player)

                if curr_player == 0:
                    if curr_point_value > best_score:
                        best_score = curr_point_value
                        best_action = action
                else:
                    best_score += float(curr_point_value) / float(len(curr_state.get_legal_actions(curr_player)))

            return best_score, best_action

        score, action = expectimax(game_state, -1, self.index)
        return action

        util.raise_not_defined()

def better_evaluation_function(current_game_state):
    """
      Your extreme ghost-hunting, pellet-nabbing, food-gobbling, unstoppable
      evaluation function (question 5).

      DESCRIPTION: <write something here so we know what you did>
    """
    curr_pos = current_game_state.get_pacman_position()
    food_pos = current_game_state.get_food()
    ghost_pos = current_game_state.get_ghost_states()

    #print(food_pos.as_list())

    score = current_game_state.get_score()

    distance_food = [manhattan_distance(curr_pos, food) for food in food_pos.as_list()]
    distance_ghost = [manhattan_distance(curr_pos, ghost_pos[i].get_position()) for i in range(len(ghost_pos))]

    if (len(distance_food) > 0 and min(distance_food) is not 0):
        score +=  10 / min(distance_food)
    if ghost_pos[0].scared_timer > 0 and min(distance_ghost) > 0:
        score += 100
    elif (min(distance_ghost) > 0):
        score -= 10 / min(distance_ghost)

    return score
    util.raise_not_defined()

# Abbreviation
better = better_evaluation_function

