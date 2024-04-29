/***
 * Name			:	ISRunner
 * Author		:	Ezio Dal Bo @TEN
 * Create Date	:	2020-10-13
 ***/
public interface ISRunner extends IRunner {
    void initRunner(List<ScheduledJob__c> schedules,Integer bSize);
    void initRunner(Integer bSize);
}