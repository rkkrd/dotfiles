#!/bin/bash

layout=$(swaymsg -t get_tree | python3 -c "
import json, sys

def find_focused_parent_layout(node, parent_layout=None):
    if node.get('focused'):
        return parent_layout or node.get('layout', 'splith')
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        result = find_focused_parent_layout(child, node.get('layout'))
        if result:
            return result
    return None

tree = json.load(sys.stdin)
layout = find_focused_parent_layout(tree)
print(layout or 'splith')
")

case "$layout" in
    splith|splitv) echo "[]=" ;;
    stacked)       echo "]]]" ;;
    tabbed)        echo "--^" ;;
    *)      echo "><>" ;;
esac
