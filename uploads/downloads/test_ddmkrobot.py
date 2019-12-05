#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @File  : test.py.py
# @Author: becivells
#@Contact : becivells@gmail.com
# @Date  : 2018/9/27
#@Software : PyCharm
# @Desc  :

#zabbix 告警

import os
import sys
import json
import logging
import argparse

import requests


# {ALERT.SENDTO}
# {ALERT.SUBJECT}
# {ALERT.MESSAGE}
#仅仅支持markdown




def parse_cmd_args():
    '''处理命令行选项
    '''
    parser = argparse.ArgumentParser(
        prog='dingding robot',
        description='dingidng robot send message for zabbix')

    parser.add_argument("--webhook", dest='webhook', action="store",
                       help="dingding webhook")

    parser.add_argument("--sendto", dest='sendto', action="store",
                       help="msg sendto")

    parser.add_argument("--subject", dest='subject', action="store",
                       help=("mesage title"))

    parser.add_argument("--message", action="store",
                       dest='message',
                       help="send message")

    parser.add_argument("--log", action="store",
                        default='/tmp/dingding.log',
                       dest='log',
                       help="log save path")

    # parser.add_argument("--msgtype", action="store", default='markdwon',
    #                     dest='msgtype',
    #                     help="user")

    args = parser.parse_args()
    if not (args.webhook and args.sendto and args.subject and args.message):
        parser.print_help()
        sys.exit(0)
    return args


headers = {'Content-Type': 'application/json;charset=utf-8'}

def dingding_markdown_msg(webhook,sendto,subject,message):
    json_text= {
     "msgtype": "markdown",
        "at": {
            "atMobiles": [
                sendto
            ],
            "isAtAll": False
        },
        "markdown": {
            "title":subject,
            "text": message
        }
    }
    try:
        info = requests.post(webhook,json.dumps(json_text),headers=headers).content
        logging.info('sendto: %s,subject: %s,message: %s,info: %s'%
                     (sendto,subject,message,info))
    except Exception as e:
        logging.error('sendto: %s,subject: %s,message: %s,info: %s'%
                      (sendto,subject,message,str(e)))


if __name__ == '__main__':
    args_msg = parse_cmd_args()
    log_path = '/tmp/'+ os.path.basename(args_msg.log)
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(thread)d %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename=log_path,
                        filemode='a'
                        )
    dingding_markdown_msg(args_msg.webhook,args_msg.sendto,
                          args_msg.subject,args_msg.message)




'''
--webhook=dingding webhook
--sendto=tel
--subject={ALERT.SUBJECT}
--message={ALERT.MESSAGE} 
--log=test.log


服务器:{HOST.NAME}发生: {TRIGGER.NAME}故障!

**告警主机:** {HOST.NAME}   
**告警地址:** {HOST.IP}   
**告警时间:** {EVENT.DATE} {EVENT.TIME}   
**监控项目:** {ITEM.NAME}   
**监控取值:** {ITEM.LASTVALUE}   
**告警等级:** {TRIGGER.SEVERITY}   
**当前状态:** {TRIGGER.STATUS}   
**告警信息:** {TRIGGER.NAME}   
**确认状态:** {EVENT.ACK.STATUS}   
**事件ID:** {EVENT.ID}


{TRIGGER.STATUS}: {TRIGGER.NAME}

**## 故障恢复提示**    
**事件名称:** {TRIGGER.NAME}   
**事件状态:** {TRIGGER.STATUS}   
**事件等级:** {TRIGGER.SEVERITY}   
**事件ID:** {EVENT.ID}   
**事件链接:** {TRIGGER.URL}   

**事件列表:**    
1. {ITEM.NAME1}({HOST.NAME1}:{ITEM.KEY1}): {ITEM.VALUE1}
'''

