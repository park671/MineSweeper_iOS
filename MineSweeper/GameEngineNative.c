//
//  GameEngineNative.cpp
//  MineSweeper
//
//  Created by youngpark on 2020/2/27.
//  Copyright © 2020 youngpark. All rights reserved.
//

#include "GameEngineNative.h"

int mapSize = 10;
int boomNum = 15;
int flagNum = 0;
bool isFlag;
bool gameFinish = false;

int** mapArray;
int** show;
bool** visit;

const int directX[] = {-1, 0, 1, -1, 1, -1, 0, 1};
const int directY[] = {1, 1, 1, 0, 0, -1, -1, -1};


/**
 * mapArray
 *
 * 0      base
 * 1 - 8  boom_num
 * -1     boom
 * -2     boom_exp
 * -3     boom_rm
 *
 **/


/**
 * show
 *
 * -2   down_flag
 * -1   down
 * 0    mask
 * 1    show
 * 2    flag
 */
void GameEngineInit() {
    printf("level = %d,  %d\n", mapSize, boomNum);
    flagNum = 0;
    gameFinish = false;
    isFlag = false;
    mapArray = (int**)malloc(sizeof(int*) *mapSize);
    for(int i = 0;i<mapSize;i++){
        mapArray[i] = (int*)malloc(sizeof(int)*mapSize);
    }
    
    show = (int**)malloc(sizeof(int*) *mapSize);
    for(int i = 0;i<mapSize;i++){
        show[i] = (int*)malloc(sizeof(int)*mapSize);
    }
    
    visit = (bool**)malloc(sizeof(bool*) *mapSize);
    for(int i = 0;i<mapSize;i++){
        visit[i] = (bool*)malloc(sizeof(bool)*mapSize);
    }
    
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            mapArray[i][j] = 0;
            show[i][j] = 0;
        }
    }
    
    /**
     * 随机放雷
     */
    for (int i = 0; i < boomNum; i++) {
        int x = rand()%mapSize;
        int y = rand()%mapSize;
        while (mapArray[x][y] == -1) {
            x = rand()%mapSize;
            y = rand()%mapSize;
        }
        mapArray[x][y] = -1;
    }
    
    /**
     * 地图数字生成
     */
    for (int x = 0; x < mapSize; x++) {
        for (int y = 0; y < mapSize; y++) {
            if (mapArray[x][y] == -1) {
                for (int j = 0; j < 8; j++) {
                    int nowX = x + directX[j];
                    int nowY = y + directY[j];
                    if (nowX >= 0 && nowY >= 0 && nowX < mapSize && nowY < mapSize && mapArray[nowX][nowY] != -1) {
                        mapArray[nowX][nowY]++;
                    }
                }
            }
        }
    }
}

void GameEngineShowAll() {
    gameFinish = true;
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            if(mapArray[i][j] == -1 && show[i][j] == 2){
                mapArray[i][j] = -3;
            }
            show[i][j] = 1;
        }
    }
}

void initBFS() {
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            visit[i][j] = false;
        }
    }
}

/**
 * youngpark 2020。02。04
 *
 * 对地图进行广度搜索，遍历出所有空地
 * @param x 坐标x
 * @param y 坐标y
 */

void bfs(int x, int y) {
    if (show[x][y] == 2) {
        flagNum--;
    }
    show[x][y] = 1;
    visit[x][y] = true;
    for (int j = 0; j < 8; j++) {
        int nowX = x + directX[j];
        int nowY = y + directY[j];
        if (nowX >= 0 && nowY >= 0 && nowX < mapSize && nowY < mapSize && !visit[nowX][nowY]) {
            if (mapArray[nowX][nowY] == 0) {
                bfs(nowX, nowY);
            } else if (mapArray[nowX][nowY] != -1) {
                if (show[nowX][nowY] == 2) {
                    flagNum--;
                }
                show[nowX][nowY] = 1;
            }
            
        }
    }
}

/**
 * mapArray
 *
 * 0      base
 * 1 - 8  boom_num
 * -1     boom
 * -2     boom_exp
 * -3     boom_rm
 *
 **/


/**
 * show
 *
 * -2   down_flag
 * -1   down
 * 0    mask
 * 1    show
 * 2    flag
 */
bool GameEngineSelectPos(int x, int y) {
    if(show[x][y] != -1)return true;
    if (mapArray[x][y] == -1) {
        mapArray[x][y] = -2;
        GameEngineShowAll();
        return false;
    } else if (mapArray[x][y] == 0) {
        initBFS();
        bfs(x, y);
        return true;
    } else {
        show[x][y] = 1;
        return true;
    }
}

bool GameEnginePressPos(int x, int y) {
    if(show[x][y] == 0){
        show[x][y] = -1;
        return true;
    }else if(show[x][y] == 2 && isFlag){
        show[x][y] = -2;
        return true;
    }
    return false;
}

bool GameEngineReleasePos(int x, int y) {
    if(show[x][y] == -1){
        show[x][y] = 0;
        return true;
    }else if(show[x][y] == -2){
        show[x][y] = 2;
        return true;
    }
    return false;
}
/**
 * 插旗
 *
 * @param x 坐标x
 * @param y 坐标y
 * @return 是否插旗成功（旗帜是有数量限制的）
 */

bool GameEngineFlag(int x, int y) {
    if (flagNum < boomNum + 1 && show[x][y] == -1) {
        show[x][y] = 2;
        flagNum++;
        return true;
    } else if (show[x][y] == -2) {
        show[x][y] = 0;
        flagNum--;
        return true;
    } else {
//        if (show[x][y] == -1) {
//            show[x][y] = 0;
//        }
        return false;
    }
}

bool GameEngineWin() {
    bool success = true;
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            if (show[i][j] != 1 && mapArray[i][j] != -1) {
                success = false;
                break;
            }
        }
    }
    if (success) {
        GameEngineShowAll();
    }
    return success;
}
