/////////////////////////////////////////////////////
///	Faith Zone Launcher Includes
///	Email&QQ 1289788020@qq.com
/////////////////////////////////////////////////////

#if defined _faith_included
  #endinput
#endif
#define _faith_included

// Faith_GetUserStatus
// 目的: 获取玩家使用状态
// 注意: 尽量在client_putinserver延迟一会儿后再进行判断, 否则有可能判断不准确
// 参数信息: (1)
// 		id: 目标玩家实体索引
// 返回值 (byte)
//		1: 玩家使用了 Faith Zone Launcher
//		0: 玩家未使用 Faith Zone Launcher
native Faith_GetUserStatus(id)

// Faith_ClientCommand
// 目的: 使目标玩家执行控制台命令, 正版有效
// 参数信息: (3)
// 		id: 目标玩家实体索引
// command: 指定命令
//     any: 任意参数, 用法与client_cmd一致
// 返回值 (无)
native Faith_ClientCommand(id, const command[], any:...)

// Faith_DrawTGA
// 目的: 在目标玩家屏幕上绘制指定的 TGA 格式的图片
// 参数信息: (12)
// 		id: 目标玩家实体索引
//		szTGA: TGA 文件路径, 不包括扩展名. 如: gfx\mypicture
//		iShow: 是否显示图片, 否的话则该通道图片立刻消失 [1= 是, 0= 否]
//		iChannel: 取值范围为 0~127, 即可以同时最多显示 128 个 TGA, 取其它值则是自动选择一个尚未使用的频道
//		iCenter: 把图片中央放在指定的坐标上 [1= 是, 0= 否]
//		fullscreen: 图片大小拉伸至全屏(自动居中)
//		iColor[4]: 分别对应 红/绿/蓝/ 透明度(0~255 数值越小越透明), 无特殊目的均为 255 如{255,255,255,255}
//		x y: 分别对应水平位置和垂直位置, 取值范围为 1~100 x 从左到右值递增, y 从上到下值递增
//		iMode: 特效 [0= 无效果, 1= 淡入淡出(根据持续时间), 2= 淡入淡出(根据淡入淡出时间)]
//		fadeintime fadeouttime: 淡入/淡出时间. 为 0 代表不使用淡入/淡出效果
//		blinktime blinkinterval: 闪烁效果持续时间/闪烁效果间隔时间
//		flTime: 图片显示时间 (小于 0 代表一直显示. 注意: 淡出效果将不可用)
//													 (问: 如何取消显示呢? 答: 再调用多一次这个函数, 将iShow设为0)
// 返回值 (无)
native Faith_DrawTGA(id, const szTGA[], iShow, iChannel, iCenter, fullscreen, iColor[4], x, y, 
				iMode, fadeintime, fadeouttime, blinktime, blinkinterval, flTime)