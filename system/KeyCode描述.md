# Android系统KEYCODE说明
## 未知按键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    0    | KEYCODE_UNKNOWN    | 未知按键 |

## 设备按键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    1    | KEYCODE_SOFTLEFT   | HOME左软键，作用可由OEM或APP指定 |
|    2    | KEYCODE_SOFT_RIGHT | HOME右软件，作用中由OEM中APP指定 |
|    3    | KEYCODE_HOME       | HOME    |
|    4    | KEYCODE_BACK       | 返回    |
|    5    | KEYCODE_CALL       | 拨号键  |
|    6    | KEYCODE_ENDCALL    | 模拟器上为黑屏，实际手机上为挂机 |
|    19   | KEYCODE_DPAD_UP    | 模拟器为DPAD_UP 小米手机无反应 |
|    20   | KEYCODE_DPAD_DOWN  | 模拟器为DPAD_DOWN 小米手机无反应 |
|    21   | KEYCODE_DPAD_LEFT  | DPAD_LEFT    |
|    22   | KEYCODE_DPAD_RIGHT | DPAD_RIGHT   |
|    23   | KEYCODE_DPAD_CENTER| DPAD_CENTER  |
|    24   | KEYCODE_VOLUME_UP  | 增加音量键    |
|    25   | KEYCODE_VOLUME_DOWN| 减小音量键    |
|    26   | KEYCODE_POWER      | 电源键        |
|    27   | KEYCODE_CAMERA     | 照像按键（部分手机有），小米上未实现 |
|    28   | KEYCODE_CLEAR      | 功能不清楚，模拟器及小米手机均无反应 |
|    78   | KEYCODE_NUM        | Num Modifier? 非NumLock|
|    79   | KEYCODE_HEADSETHOOK| 耳机Hook按键  |
|    80   | KEYCODE_FOCUS      | 拍照对焦键，索尼等手机有此键 |
|    82   | KEYCODE_MENU       | Menu键 AOSP:桌面相当于长按桌面空白处，APP中相当于点击App的菜单栏 MI:总是相当于按下ResentApps按键 |
|    84   | KEYCODE_SEARCH     | 启动桌面搜索或是进入APP的搜索功能 |
|    91   | KEYCODE_MUTE       | 麦克风静音     |
|   220   | KEYCODE_BRIGHTNESS_DOWN | 降低屏幕亮度 |
|   221   | KEYCODE_BRIGHTNESS_UP   | 增加屏幕亮度 |


## 一键启动应用
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    64   | KEYCODE_EXPLORER   | 打开浏览器    |
|    65   | KEYCODE_ENVELOPE   | 打开邮件      |
|   207   | KEYCODE_CONTACTS   | 打开联系人    |
|   208   | KEYCODE_CALENDAR   | 打开日历应用  |
|   209   | KEYCODE_MUSIC      | 打开音乐应用  |
|   210   | KEYCODE_CALCULATOR | 打开计算器应用|
|   219   | KEYCODE_ASSIST     | 打开系统的助手程序，相当于Siri 该键值不会被传递到应用|     

## 数字
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    7    | KEYCODE_0          | 0       |
|    8    | KEYCODE_1          | 1       |
|    9    | KEYCODE_2          | 2       |
|    10   | KEYCODE_3          | 3       |
|    11   | KEYCODE_4          | 4       |
|    12   | KEYCODE_5          | 5       |
|    13   | KEYCODE_6          | 6       |
|    14   | KEYCODE_7          | 7       |
|    15   | KEYCODE_8          | 8       |
|    16   | KEYCODE_9          | 9       |
|    17   | KEYCODE_STAR       | 模拟器为* 小米手机默认无反应，输入中文过程中为＊|
|    18   | KEYCODE_POUND      | 模拟器为# 小米手机默认为切换输入法，输入中文过程中为＃ |

## 字母
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    29   | KEYCODE_A          | a            |
|    30   | KEYCODE_B          | b            |
|    31   | KEYCODE_C          | c            |
|    32   | KEYCODE_D          | d            |
|    33   | KEYCODE_E          | e            |
|    34   | KEYCODE_F          | f            |
|    35   | KEYCODE_G          | g            |
|    36   | KEYCODE_H          | h            |
|    37   | KEYCODE_I          | i            |
|    38   | KEYCODE_J          | j            |
|    39   | KEYCODE_K          | k            |
|    40   | KEYCODE_L          | l            |
|    41   | KEYCODE_M          | m            |
|    42   | KEYCODE_N          | n            |
|    43   | KEYCODE_O          | o            |
|    44   | KEYCODE_P          | p            |
|    45   | KEYCODE_Q          | q            |
|    46   | KEYCODE_R          | r            |
|    47   | KEYCODE_S          | s            |
|    48   | KEYCODE_T          | t            |
|    49   | KEYCODE_U          | u            |
|    50   | KEYCODE_V          | v            |
|    51   | KEYCODE_W          | w            |
|    52   | KEYCODE_X          | x            |
|    53   | KEYCODE_Y          | y            |
|    54   | KEYCODE_Z          | z            |

## 符号
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    55   | KEYCODE_COMMA      | ,            |
|    56   | KEYCODE_PERIOD     | .            |
|    61   | KEYCODE_TAB        | Tab键        |
|    62   | KEYCODE_SPACE      | 空格键       |
|    68   | KEYCODE_GRAVE      | ` 反引号键位于PC键盘Tab键上方|
|    69   | KEYCODE_MINUS      | - 减号       |
|    70   | KEYCODE_EQUALS     | = 等号       |
|    71   | KEYCODE_LEFT_BRACKET| [ 左中括号   |
|    72   | KEYCODE_RIGHT_BRACKET|] 右中括号   |
|    73   | KEYCODE_BACKSLASH  | \ 反斜线     |
|    74   | KEYCODE_SEMICOLON  | ; 分号       |
|    75   | KEYCODE_APOSTROPHE | ' 单引号     |
|    76   | KEYCODE_SLASH      | / 斜线       |
|    77   | KEYCODE_AT         | @ at符号     |
|    81   | KEYCODE_PLUS       | + 加号       |

## 控制按键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|   115   | KEYCODE_CAPS_LOCK  | CapsLock键    |
|   116   | KEYCODE_SCROLL_LOCK| ScrLk键       |
|   120   | KEYCODE_SYSRQ      | SysRq/PrtScr  |
|   121   | KEYCODE_BREAK      | Pause/Break键 |

## 编辑键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    63   | KEYCODE_SYM        | 更改键盘      |
|    66   | KEYCODE_ENTER      | 回车键        |
|    67   | KEYCODE_DEL        | Backspace键  |
|    83   | KEYCODE_NOTIFICATION| 通知键，作用未知 |
|    92   | KEYCODE_PAGE_UP    | PgUp键        |
|    93   | KEYCODE_PAGE_DOWN  | PgDn键        |
|    94   | KEYCODE_PICTSYMBOLS| Picture Symbols modifier，用于切换符号集如Emoji<->Kao-moji |
|    95   | KEYCODE_SWITCH_CHARSET| 切换字符集如Kanji<->Katakana |
|   111   | KEYCODE_ESC        | Esc键         |
|   112   | KEYCODE_FORWARD_DEL| Del键         |
|   122   | KEYCODE_MOVE_HOME  | 光标移动到行首 |
|   123   | KEYCODE_MOVE_END   | 光标移动到行尾 |
|   124   | KEYCODE_INSERT     | Insert键      |
|   125   | KEYCODE_FORWARD    | Navigates forward in the history stack? |

## 组合键用键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    57   | KEYCODE_ALT_LEFT   | 左Alt键      |
|    58   | KEYCODE_ALT_RIGHT  | 右Alt键      |
|    59   | KEYCODE_SHIFT_LEFT | 左Shift键    |
|    60   | KEYCODE_SHIFT_RIGHT| 右Shift键    |
|   113   | KEYCODE_CTRL_LEFT  | 左Ctrl键      |
|   114   | KEYCODE_CTRL_RIGHT | 右Ctrl键      |
|   117   | KEYCODE_META_LEFT  | Mac左Meta键 对应于PC Alt |
|   118   | KEYCODE_META_RIGHT | Mac右Meta键 对应于PC Alt |
|   119   | KEYCODE_FUNCTION   | Fn键          |

## 功能按键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|   131   | KEYCODE_F1         | F1键          |
|   132   | KEYCODE_F2         | F2键          |
|   133   | KEYCODE_F3         | F3键          |
|   134   | KEYCODE_F4         | F4键          |
|   135   | KEYCODE_F5         | F5键          |
|   136   | KEYCODE_F6         | F6键          |
|   137   | KEYCODE_F7         | F7键          |
|   138   | KEYCODE_F8         | F8键          |
|   139   | KEYCODE_F9         | F9键          |
|   140   | KEYCODE_F10        | F10键         |
|   141   | KEYCODE_F11        | F11键         |
|   142   | KEYCODE_F12        | F12键         |

## 数字键盘
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|   143   | KEYCODE_NUM_LOCK   | NumLock键     |
|   144   | KEYCODE_NUMPAD_0   | 数字键盘0      |
|   145   | KEYCODE_NUMPAD_1   | 数字键盘1      |
|   146   | KEYCODE_NUMPAD_2   | 数字键盘2      |
|   147   | KEYCODE_NUMPAD_3   | 数字键盘3      |
|   148   | KEYCODE_NUMPAD_4   | 数字键盘4      |
|   149   | KEYCODE_NUMPAD_5   | 数字键盘5      |
|   150   | KEYCODE_NUMPAD_6   | 数字键盘6      |
|   151   | KEYCODE_NUMPAD_7   | 数字键盘7      |
|   152   | KEYCODE_NUMPAD_8   | 数字键盘8      |
|   153   | KEYCODE_NUMPAD_9   | 数字键盘9      |
|   154   | KEYCODE_NUMPAD_DIVIDE| 数字键盘/    |
|   155   | KEYCODE_NUMPAD_MULTIPLY | 数字键盘* |
|   156   | KEYCODE_NUMPAD_SUBTRACT | 数字键盘- |
|   157   | KEYCODE_NUMPAD_ADD | 数字键盘+      |
|   158   | KEYCODE_NUMPAD_DOT | 数字键盘.      |
|   159   | KEYCODE_NUMPAD_COMMA| 数字键盘,     |
|   160   | KEYCODE_NUMPAD_ENTER| 数字键盘Enter |
|   161   | KEYCODE_NUMPAD_EQUALS| 数字键盘=    |
|   162   | KEYCODE_NUMPAD_LEFT_PAREN| 数字键盘(|
|   163   | KEYCODE_NUMPAD_RIGHT_PAREN| 数字键盘)|

## 遥控或设备面板常用键
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    91   | KEYCODE_MUTE        | 麦克风静音      |
|   164   | KEYCODE_VOLUME_MUTE | 扬声器静音/恢复 |
|   165   | KEYCODE_INFO        | 常见于电视遥控器，用于显示当前节目的附加信息 |
|   166   | KEYCODE_CHANNEL_UP  | 频道+          |
|   167   | KEYCODE_CHANNEL_DOWN| 频道-          |
|   168   | KEYCODE_ZOOM_IN     | 放大           |
|   168   | KEYCODE_ZOOM_OUT    | 缩小           |
|   170   | KEYCODE_TV          | TV键，切换到电视|
|   171   | KEYCODE_WINDOW      | 窗口键，电视画中画，或其他窗口功能 |
|   172   | KEYCODE_GUIDE       | 导播键         |
|   173   | KEYCODE_DVR         | 切换到DVR模式录制节目 |
|   174   | KEYCODE_BOOKMARK    | 收藏键，收藏内容或网页 |
|   175   | KEYCODE_CAPTIONS    | 切换隐藏字幕    |
|   176   | KEYCODE_SETTINGS    | 设置键，系统设置|
|   177   | KEYCODE_TV_POWER    | 电视电源键      |
|   178   | KEYCODE_TV_INPUT    | 信号源键        |
|   179   | KEYCODE_STB_POWER   | 外置机顶盒电源键 |
|   180   | KEYCODE_STB_INPUT   | 切换外置机顶盒输入模式 |
|   181   | KEYCODE_AVR_POWER   | 外置A/V接收器电源键 |
|   182   | KEYCODE_AVR_INPUT   | 切换A/V接收器输入模式 |
|   183   | KEYCODE_PROG_RED    | 可编程键“红” |
|   184   | KEYCODE_PROG_GREEN  | 可编程键“绿” |
|   185   | KEYCODE_PROG_YELLOW | 可编程键“黄” |
|   186   | KEYCODE_PROG_BLUE   | 可编程键“蓝” |
|   187   | KEYCODE_APP_SWITCH  | 打开应用切换对话框 |
|   204   | KEYCODE_LANGUAGE_SWITCH | 切换输入语言 |
|   205   | KEYCODE_MANNER_MODE | 切换礼貌模式，设置静音、振动等开关以便在特定场合更礼貌 |
|   206   | KEYCODE_3D_MODE     | 切换3D/2D模式|
|   203   | KEYCODE_BUTTON_16   | 通用按钮#16  |
|   203   | KEYCODE_BUTTON_16   | 通用按钮#16  |
|   203   | KEYCODE_BUTTON_16   | 通用按钮#16  |
|   203   | KEYCODE_BUTTON_16   | 通用按钮#16  |


## 媒体控制
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|    85   | KEYCODE_MEDIA_PLAY_PAUSE| 播放/暂停键 |
|    86   | KEYCODE_MEDIA_STOP | 停止键 |
|    87   | KEYCODE_MEDIA_NEXT | 下一首 |
|    88   | KEYCODE_MEDIA_PREVIOUS| 前一首 |
|    89   | KEYCODE_MEDIA_REWIND| 倒退键 |
|    90   | KEYCODE_MEDIA_FAST_FORWARD| 快进键 小米内置音乐软件无效|
|   126   | KEYCODE_MEDIA_PLAY | 播放键 |
|   127   | KEYCODE_MEDIA_PAUSE| 暂停键 |
|   128   | KEYCODE_MEDIA_CLOSE| 关闭CD仓门 |
|   129   | KEYCODE_MEDIA_EJECT| 弹开CD仓门 |
|   130   | KEYCODE_MEDIA_RECORD| 录制键    |
|   222   | KEYCODE_MEDIA_AUDIO_TRACK | 切换音轨 |
|   223   | KEYCODE_SLEEP      | 睡眠键，类似电源键，不同的是已经睡眠时，此键将被忽略 |
|   224   | KEYCODE_WAKEUP     | 唤醒键，类似电源键，不同的是运行状态时，此键将被忽略 |

## 游戏控制器
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |

|    96   | KEYCODE_BUTTON_A        | 按钮A               |
|    97   | KEYCODE_BUTTON_B        | 按钮B               |
|    98   | KEYCODE_BUTTON_C        | 按钮C               |
|    99   | KEYCODE_BUTTON_X        | 按钮X               |
|   100   | KEYCODE_BUTTON_Y        | 按钮Y               |
|   101   | KEYCODE_BUTTON_Z        | 按钮Z               |
|   102   | KEYCODE_BUTTON_L1       | 通常标有L1或L        |
|   103   | KEYCODE_BUTTON_R1       | 通常标有R1或R        |
|   104   | KEYCODE_BUTTON_L1       | 通常标有L2或为左手扳机|
|   105   | KEYCODE_BUTTON_R1       | 通常标有R2或为右手扳机|
|   106   | KEYCODE_BUTTON_THUMBL   | 左拇指按钮           |
|   107   | KEYCODE_BUTTON_THUMBR   | 右拇指按钮           |
|   108   | KEYCODE_BUTTON_START    | 按钮START           |
|   109   | KEYCODE_BUTTON_SELECT   | 按钮SELECT          |
|   110   | KEYCODE_BUTTON_MODE     | 按钮MODE            |
|   188   | KEYCODE_BUTTON_1        | 通用按钮#1     也有可能用于遥控器  |
|   189   | KEYCODE_BUTTON_2        | 通用按钮#2   |
|   190   | KEYCODE_BUTTON_3        | 通用按钮#3   |
|   191   | KEYCODE_BUTTON_4        | 通用按钮#4   |
|   192   | KEYCODE_BUTTON_5        | 通用按钮#5   |
|   193   | KEYCODE_BUTTON_6        | 通用按钮#6   |
|   194   | KEYCODE_BUTTON_7        | 通用按钮#7   |
|   195   | KEYCODE_BUTTON_8        | 通用按钮#8   |
|   196   | KEYCODE_BUTTON_9        | 通用按钮#9   |
|   197   | KEYCODE_BUTTON_10       | 通用按钮#10  |
|   198   | KEYCODE_BUTTON_11       | 通用按钮#11  |
|   199   | KEYCODE_BUTTON_12       | 通用按钮#12  |
|   200   | KEYCODE_BUTTON_13       | 通用按钮#13  |
|   201   | KEYCODE_BUTTON_14       | 通用按钮#14  |
|   202   | KEYCODE_BUTTON_15       | 通用按钮#15  |
|   203   | KEYCODE_BUTTON_16       | 通用按钮#16  |

## 日文相关
|  键值   |  键名     |  相当于按键  |
| :-----: | :------- | :-------------  |
|   211   | KEYCODE_ZENKAKU_HANKAKU | Japanese full-width / half-width key |
|   212   | KEYCODE_EISU            | Japanese alphanumeric key |
|   213   | KEYCODE_MUHENKAN        | Japanese non-conversion key |
|   214   | KEYCODE_HENKAN          | Japanese conversion key   |
|   215   | KEYCODE_KATAKANA_HIRAGANA | Japanese katakana / hiragana key |
|   216   | KEYCODE_YEN             | Japanese Yen key          |
|   217   | KEYCODE_RO              | Japanese Ro key           |
|   218   | KEYCODE_KANA            | Japanese kana key         |
