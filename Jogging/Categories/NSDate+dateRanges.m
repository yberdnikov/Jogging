//
//  NSDate+dateRanges.m
//  dateRanges
//
//  Created by John Nye on 27/01/2013.
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

#import "NSDate+dateRanges.h"

@implementation NSDate (dateRanges)

#pragma mark current ranges
-(NSDate*)startOfDay
{
    return [self startOfDayWithOffset:0];
}

-(NSDate*)endOfDay
{
    return [self endOfDayWithOffset:0];
}

-(NSDate*)startOfThisWeek
{
    return [self startOfWeekWithOffset:0];
}

-(NSDate*)endOfThisWeek
{
    return [self endOfWeekWithOffset:0];
}

-(NSDate*)startOfThisMonth
{
    return [self startOfMonthWithOffset:0];
}

-(NSDate*)endOfThisMonth
{
    return [self endOfMonthWithOffset:0];
}

-(NSDate*)startOfThisYear
{
    return [self startOfYearWithOffset:0];
}
-(NSDate*)endOfThisYear
{
    return [self endOfYearWithOffset:0];
}



#pragma mark past ranges
-(NSDate*)startOfDayBefore
{
    return [self startOfDayWithOffset:-1];
}

-(NSDate*)endOfDayBefore
{
    return [self endOfDayWithOffset:-1];
}


-(NSDate*)startOfWeekBefore
{
    return [self startOfWeekWithOffset:-1];
}

-(NSDate*)endOfWeekBefore
{
    return [self endOfWeekWithOffset:-1];
}

-(NSDate*)startOfMonthBefore
{
    return [self startOfMonthWithOffset:-1];
}

-(NSDate*)endOfMonthBefore
{
    return [self endOfMonthWithOffset:-1];
}

-(NSDate*)startOfYearBefore
{
    return [self startOfYearWithOffset:-1];
}

-(NSDate*)endOfYearBefore
{
    return [self endOfYearWithOffset:-1];
}


#pragma Mark future ranges
-(NSDate*)startOfNextDay
{
    return [self startOfDayWithOffset:1];
}

-(NSDate*)endOfNextDay
{
    return [self endOfDayWithOffset:1];
}

-(NSDate*)startOfNextWeek
{
    return [self startOfWeekWithOffset:1];
}

-(NSDate*)endOfNextWeek
{
    return [self endOfWeekWithOffset:1];
}

-(NSDate*)startOfNextMonth
{
    return [self startOfMonthWithOffset:1];
}

-(NSDate*)endOfNextMonth
{
    return [self endOfMonthWithOffset:1];
}

-(NSDate*)startOfNextYear
{
    return [self startOfYearWithOffset:1];
}

-(NSDate*)endOfNextYear
{
    return [self endOfYearWithOffset:1];
}

#pragma mark Any Range
-(NSDate*)startOfDayWithOffset:(int)offset
{

    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [weekdayComponents setDay:[weekdayComponents day]+offset];
    
    return [gregorian dateFromComponents: weekdayComponents] ;

}

-(NSDate*)endOfDayWithOffset:(int)offset
{

    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [weekdayComponents setDay:[weekdayComponents day]+offset+1];
    
    return [gregorian dateFromComponents: weekdayComponents] ;
}

-(NSDate*)startOfWeekWithOffset:(int)offset
{
    offset = offset -1;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:self];
    [components setWeekday:1];
    [components setWeek:[components week]+offset];

    return [gregorian dateFromComponents: components];
}

-(NSDate*)endOfWeekWithOffset:(int)offset
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:self];
    [components setWeekday:7];
    [components setWeek:[components week]+offset];
    return [gregorian dateFromComponents: components];
}

-(NSDate*)startOfMonthWithOffset:(int)offset
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    NSDate *startOfMonthDate = nil;
    NSDateComponents *components = nil;
    
    [componentsToSubtract setMonth: offset];
    startOfMonthDate = [gregorian dateByAddingComponents:componentsToSubtract toDate:self options:0];
    components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit) fromDate: startOfMonthDate];
    
    return [gregorian dateFromComponents: components];
}

-(NSDate*)endOfMonthWithOffset:(int)offset
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    

    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    NSDateComponents *components = nil;
    NSDate *endOfMonthDate = nil;
    
    [componentsToSubtract setMonth: (offset+1)];
    endOfMonthDate = [gregorian dateByAddingComponents:componentsToSubtract toDate:self options:0];
    components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit) fromDate: endOfMonthDate];
    
    return [[gregorian dateFromComponents: components] dateByAddingTimeInterval:0];
}

-(NSDate*)startOfYearWithOffset:(int)offset
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    NSDateComponents *yearComponents = [gregorian components:NSYearCalendarUnit fromDate:self];
    [yearComponents setYear:[yearComponents year]+offset];
    return [gregorian dateFromComponents: yearComponents];
}

-(NSDate*)endOfYearWithOffset:(int)offset
{
    offset = offset+1;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *yearComponents = [gregorian components:NSYearCalendarUnit fromDate:self];
    [yearComponents setYear:[yearComponents year]+offset];
    return [gregorian dateFromComponents: yearComponents];}

@end