//
//  NSDate+dateRanges.h
//  dateRanges
//
//  Created by John Nye on 27/01/2013.
//  Copyright (c) 2013 NimbleWorks LLP. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <Foundation/Foundation.h>

@interface NSDate (dateRanges)

//preset current ranges
-(NSDate*)startOfDay;
-(NSDate*)endOfDay;
-(NSDate*)startOfThisWeek;
-(NSDate*)endOfThisWeek;
-(NSDate*)startOfThisMonth;
-(NSDate*)endOfThisMonth;
-(NSDate*)startOfThisYear;
-(NSDate*)endOfThisYear;

//preset past ranges
-(NSDate*)startOfDayBefore;
-(NSDate*)endOfDayBefore;
-(NSDate*)startOfWeekBefore;
-(NSDate*)endOfWeekBefore;
-(NSDate*)startOfMonthBefore;
-(NSDate*)endOfMonthBefore;
-(NSDate*)startOfYearBefore;
-(NSDate*)endOfYearBefore;

//Preset future ranges
-(NSDate*)startOfNextDay;
-(NSDate*)endOfNextDay;
-(NSDate*)startOfNextWeek;
-(NSDate*)endOfNextWeek;
-(NSDate*)startOfNextMonth;
-(NSDate*)endOfNextMonth;
-(NSDate*)startOfNextYear;
-(NSDate*)endOfNextYear;

//ranges with any configuration
-(NSDate*)startOfDayWithOffset:(int)offset;
-(NSDate*)endOfDayWithOffset:(int)offset;
-(NSDate*)startOfWeekWithOffset:(int)offset;
-(NSDate*)endOfWeekWithOffset:(int)offset;
-(NSDate*)startOfMonthWithOffset:(int)offset;
-(NSDate*)endOfMonthWithOffset:(int)offset;
-(NSDate*)startOfYearWithOffset:(int)offset;
-(NSDate*)endOfYearWithOffset:(int)offset;

@end
