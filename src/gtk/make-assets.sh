#! /usr/bin/env bash

for theme in '' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey'; do
    case "$theme" in
      '')
        theme_color_dark='#1A73E8'
        theme_color_light='#3281EA'
        ;;
      -purple)
        theme_color_dark='#AB47BC'
        theme_color_light='#BA68C8'
        ;;
      -pink)
        theme_color_dark='#EC407A'
        theme_color_light='#F06292'
        ;;
      -red)
        theme_color_dark='#E53935'
        theme_color_light='#F44336'
        ;;
      -orange)
        theme_color_dark='#F57C00'
        theme_color_light='#FB8C00'
        ;;
      -yellow)
        theme_color_dark='#FBC02D'
        theme_color_light='#FFD600'
        ;;
      -green)
        theme_color_dark='#4CAF50'
        theme_color_light='#66BB6A'
        ;;
      -teal)
        theme_color_dark='#009688'
        theme_color_light='#4DB6AC'
        ;;
      -grey)
        theme_color_dark='#464646'
        theme_color_light='#DDDDDD'
        ;;
    esac

  cp -rf "assets.svg" "assets${theme}.svg"
  sed -i "s/#1A73E8/${theme_color_dark}/g" "assets${theme}.svg"
  sed -i "s/#3281EA/${theme_color_light}/g" "assets${theme}.svg"
done

echo -e "DONE!"
