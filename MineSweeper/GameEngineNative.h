//
//  GameEngineNative.hpp
//  MineSweeper
//
//  Created by youngpark on 2020/2/27.
//  Copyright © 2020 youngpark. All rights reserved.
//

#ifndef GameEngineNative_hpp
#define GameEngineNative_hpp

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

extern int mapSize;
extern int boomNum;
extern int flagNum;
extern bool isFlag;
extern bool gameFinish;

extern int** mapArray;
extern int** show;
extern bool** visit;

void GameEngineInit(void);
void GameEngineShowAll(void);
bool GameEnginePressPos(int x, int y);
bool GameEngineSelectPos(int x, int y);
bool GameEngineReleasePos(int x, int y);
bool GameEngineFlag(int x, int y);
bool GameEngineWin(void);

#endif /* GameEngineNative_hpp */
