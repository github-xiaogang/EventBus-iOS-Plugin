#!/bin/sh

#  find.sh
#  XToDo
#
#  Created by Travis on 13-11-28.
#  Copyright (c) 2013年 Plumn LLC. All rights reserved.


REGEX="((@interface.*< *(EventAsyncPublisher|EventSyncPublisher|EventAsyncSubscriber|EventSyncSubscriber).*>)|((EVENT_SUBSCRIBE|EVENT_PUBLISH|EVENT_PUBLISH_WITHDATA) *\(.+\)))"

find "$1" \( -name "*.h" -or -name "*.m" -or -name "*.mm" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "$REGEX"