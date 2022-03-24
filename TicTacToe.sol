// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0;

// This is going to be very expensive
// TODO: Make it less expensive
contract TicTacToe {
  bool private gameOver = false;
  bool private player1Turn = true;
  bool private draw = false;
  uint8 private boardSize = 3;
  uint8 private turns = 1;
  string[] private board;
  string public winner = "Game still in session. Please complete the game to view a winner.";

  constructor() {
    createBoard(boardSize);
  }

  function compareStrings(string memory a, string memory b) private pure returns (bool) {
    return (keccak256(abi.encodePacked((a)))) == keccak256(abi.encodePacked((b)));
  }

  function setWinner() private {
    if (!draw) {
      if (player1Turn) winner = "Player 1 wins.";
      else winner = "Player 2 wins.";
    } else winner = "Cat's game. Everyone loses.";
  }

  function showBoard() public view returns (string[] memory) {
    return board;
  }

  function showTurn() public view returns (string memory) {
    if (player1Turn) return "Player 1's turn.";
    else return "Player 2's turn.";
  }

  function createBoard(uint256 _boardSize) private {
    for (uint8 i = 0; i < _boardSize**2; i++) {
      board.push("");
    }
  }

  modifier onlyGameOver() {
    require(gameOver == true, "Game still in session. Please complete the game to begin a new one.");
    _;
  }

  function newGame() onlyGameOver public {
    gameOver = false;
    player1Turn = true;
    turns = 1;
    winner = "Game still in session. Please complete the game to view a winner.";
    for (uint8 i = 0; i < boardSize**2; i++) {
      board[i] = "";
    }
  }

  function playMove(int8 move_idx) public {
    require(gameOver == false, "Game has ended. Call newGame() to restart.");
    require(move_idx > 0 && move_idx <= int8(boardSize**2), "Invalid move.");
    require(!compareStrings(board[uint8(move_idx) - 1], "X") && !compareStrings(board[uint8(move_idx) - 1], "O"), "Space occupied. Please play another move.");

    if (player1Turn) {
      board[uint8(move_idx) - 1] = "X";
    } else {
      board[uint8(move_idx) - 1] = "O";
    }

    // Only check for winner if amount of turns is at least equal to minimum amount of turns required to win based on board size
    // e.g. on 3x3 board 5 turns must be played (3 for player 1, 2 for player 2)
    if (turns >= boardSize*2 - 1) {
      if (checkBoard()) gameOver = true;
    }

    turns += 1;
    player1Turn = !player1Turn;
  }

  function checkBoard() private returns (bool) {
    string memory checkFor = "X";

    if (!player1Turn) {
      checkFor = "O";
    }

    string[] memory line = new string[](boardSize);
    bool lineUp;

    // Check rows
    for (uint8 i = 0; i < boardSize; i++) {
      lineUp = true;
      uint8 index = 0;

      for (uint8 j = i * boardSize; j < (i * boardSize) + boardSize; j++) {
        line[index] = board[j];
        index++;
      }

      for (uint8 j = 0; j < boardSize; j++) {
        if (compareStrings(line[j], checkFor) == false) {
          lineUp = false;
        }
      }

      if (lineUp) {
        setWinner();
        return true;
      } 
    }

    // Check columns
    for (uint8 i = 0; i < boardSize; i++) {
      uint8 columnNext = i + boardSize;
      lineUp = true;
      line[0] = board[i];

      for (uint8 j = 1; j < boardSize; j++) {
        line[j] = board[columnNext];
        columnNext += boardSize;
      }

      for (uint8 j = 0; j < boardSize; j++) {
        if (compareStrings(line[j], checkFor) == false) {
          lineUp = false;
        }
      }

      if (lineUp) {
        setWinner();
        return true;
      }
    }

    // Check diagonals
    lineUp = true;
    line[0] = board[0];

    for (uint8 i = 1; i < boardSize; i++) {
      line[i] = board[i * (boardSize + 1)];
    }

    for (uint8 j = 0; j < boardSize; j++) {
      if (compareStrings(line[j], checkFor) == false) {
        lineUp = false;
      }
    }

    if (lineUp) {
      setWinner();
      return true;
    }

    lineUp = true;

    for (uint8 i = 0; i < boardSize; i++) {
      line[i] = board[(i + 1) * (boardSize - 1)];
    }

    for (uint8 j = 0; j < boardSize; j++) {
      if (compareStrings(line[j], checkFor) == false) {
        lineUp = false;
      }
    }

    if (lineUp) {
      setWinner();
      return true;
    }

    if (turns == boardSize**2) {
      draw = true;
      setWinner();
    } 

    return false;
  }
}