#! /bin/bash
:<<!
  设置屏幕分辨率的脚本(xrandr命令的封装)
  one: 只展示一个内置屏幕 2560x1600 缩放为 1440x900
  two: 左边展示外接屏幕 - 右边展示内置屏幕 都用匹配1080p屏幕DPI的缩放比
  check: 检测显示器连接状态是否变化 变化则自动调整输出情况
!


MODE=LR           # LR 左右 TB 上下
INNER_PORT=eDP-1  # 定义内置屏幕接口

[ "$(xrandr | grep '3440x1440')" ] && MODE=H$MODE # 相应的高分辨率模式

setbg() {
    feh --randomize --bg-fill ~/Pictures/wallpaper/*.png
}

two() {
    # 查找已连接、未连接的外接接口
    OUTPORT_CONNECTED=$(xrandr | grep -v $INNER_PORT | grep -w 'connected' | awk '{print $1}')
    [ ! "$OUTPORT_CONNECTED" ] && one && return # 如果没有外接屏幕则直接调用one函数

    for sc in $(xrandr | grep -w 'disconnected' | awk '{print $1}'); do xrandr --output $sc --off; done

    [ $MODE = "LR" ] && \
        xrandr --output $INNER_PORT --mode 2880x1800 --pos 1920x320 --scale 0.5x0.5 \
               --output $OUTPORT_CONNECTED --mode 1920x1080 --pos 0x0 --scale 0.9999x0.9999 --primary \

    [ $MODE = "TB" ] && \
        xrandr --output $INNER_PORT --mode 2880x1800 --pos 500x1080 --scale 0.5x0.5 \
               --output $OUTPORT_CONNECTED --mode 1920x1080 --pos 0x0 --scale 0.9999x0.9999 --primary \

    [ $MODE = "HLR" ] && \
        xrandr --output $INNER_PORT --mode 2880x1800 --pos 2560x320 --scale 0.5x0.5 \
               --output $OUTPORT_CONNECTED --mode 2560x1080 --pos 0x0 --scale 0.9999x0.9999 --primary \

    [ $MODE = "HTB" ] && \
        xrandr --output $INNER_PORT --mode 2880x1800 --pos 500x1080 --scale 0.5x0.5 \
               --output $OUTPORT_CONNECTED --mode 2560x1080 --pos 0x0 --scale 0.9999x0.9999 --primary \

    setbg
}
one() {
    for sc in $(xrandr | grep -w 'disconnected' | awk '{print $1}'); do xrandr --output $sc --off; done
    xrandr --output $INNER_PORT --mode 2880x1800 --pos 0x0 --scale 0.5x0.5 --primary \
    setbg
}
check() {
    CONNECTED_PORTS=$(xrandr | grep -w 'connected' | awk '{print $1}' | wc -l)
    CONNECTED_MONITORS=$(xrandr --listmonitors | sed 1d | awk '{print $4}' | wc -l)
    [ $CONNECTED_PORTS -gt $CONNECTED_MONITORS ] && two # 如果当前连接接口多于当前输出屏幕 则调用two
    [ $CONNECTED_PORTS -lt $CONNECTED_MONITORS ] && one # 如果当前连接接口少于当前输出屏幕 则调用one
}

case $1 in
    one) one ;;
    two) two ;;
    check) check ;;
    *) check ;;
esac
