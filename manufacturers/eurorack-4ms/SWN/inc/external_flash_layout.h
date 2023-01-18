#pragma once

#include <stm32f7xx.h>
#include "flash_S25FL127.h"

#define 	STARTUP_PRESET_SETTING_SECTOR 14
#define 	WT_SECTOR_START 		16
#define		PRESET_SECTOR_START		217
#define		PRESETS_PER_SECTOR		2

#define		MAX_WT_IN_FLASH  		(PRESET_SECTOR_START - WT_SECTOR_START - 1)									/* 200 */
#define		MAX_PRESETS  			((sFLASH_SPI_NUM_SECTORS - PRESET_SECTOR_START) * PRESETS_PER_SECTOR)		/* 108 */