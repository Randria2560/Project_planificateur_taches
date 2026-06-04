#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#define BUF 512

void list_task(void) {     //lire le crontab
    FILE *f = popen("crontab -l 2>/dev/null", "r");
    char line[BUF];
    int n = 0, found = 0;
    while (fgets(line, sizeof line, f)) 
    { 
        printf("%d\t%s", ++n, line); 
        found = 1; 
    }
    pclose(f);
    if (!found)
    {
        puts("No scheduled tasks found.");
    }
    puts("Press Enter to continue..."); 
    getchar();
}

void add_task(void) //écrire dans le crontab
{
    char cmd[BUF], min[16]="*", hr[16]="*", dom[16]="*", mon[16]="*", dow[16]="*";
    int choice; 
    char log[BUF];

    printf("Command: "); 
    fgets(cmd, sizeof(cmd), stdin);   //lire depuis l'éntrée standard
    cmd[strcspn(cmd, "\n")] = 0;   //vider le \n    //a ne pas oublier

    puts("1.Hourly 2.Daily 3.Weekly 4.Monthly 5.Custom");
    printf("Choice: "); 
    scanf("%d", &choice); 
    getchar();

    switch (choice) 
    {
        case 1: printf("Minute(0-59): "); scanf("%15s", min); getchar(); break;
        case 2: printf("Hour(0-23): ");   scanf("%15s", hr);  getchar();
                printf("Minute(0-59): "); scanf("%15s", min); getchar(); break;
        case 3: printf("Day(0-6): ");     scanf("%15s", dow); getchar();
                printf("Hour(0-23): ");   scanf("%15s", hr);  getchar();
                printf("Minute(0-59): "); scanf("%15s", min); getchar(); break;
        case 4: printf("Day(1-31): ");    scanf("%15s", dom); getchar();
                printf("Hour(0-23): ");   scanf("%15s", hr);  getchar();
                printf("Minute(0-59): "); scanf("%15s", min); getchar(); break;
        case 5: printf("Min: ");  scanf("%15s", min); getchar();
                printf("Hour: "); scanf("%15s", hr);  getchar();
                printf("DOM: ");  scanf("%15s", dom); getchar();
                printf("Mon: ");  scanf("%15s", mon); getchar();
                printf("DOW: ");  scanf("%15s", dow); getchar(); break;
    }


    printf("Enable logs? (yes/no): "); 
    fgets(log, sizeof(log), stdin);
    log[strcspn(log, "\n")] = 0;   //vider le \n


    for (int i = 0; log[i]; i++) 
    {
        log[i] = tolower(log[i]);
    }
    if (strcmp(log, "yes") == 0)
    {
        strncat(cmd, " >> scheduler.log 2>&1", sizeof(cmd)-strlen(cmd)-1);
    }
    char cron[BUF];
    snprintf(cron, sizeof(cron), "%s %s %s %s %s %s", min, hr, dom, mon, dow, cmd);

    /* check duplicate */
    char check[BUF * 2];
    snprintf(check, sizeof(check), "crontab -l 2>/dev/null | grep -qF '%s'", cron);
    if (system(check) == 0) 
    {   
        puts("Task already exists."); 
    }
    else 
    {
        char add[BUF * 4];
        snprintf(add, sizeof add,"(crontab -l 2>/dev/null; echo '%s') | crontab -", cron);
        system(add);
        printf("Task added: %s\n", cron);
    }
    puts("Press Enter to continue..."); 
    getchar();
}

void remove_task(void) 
{
    FILE *f = popen("crontab -l 2>/dev/null", "r");
    char line[BUF];
    int n = 0, found = 0;
    while (fgets(line, sizeof line, f)) 
    { 
        printf("%d\t%s", ++n, line); 
        found = 1; 
    }
    pclose(f);
    if (!found) 
    { 
        puts("No scheduled tasks found."); 
        getchar(); 
        return; 
    }
    int nbr;
    printf("Line to remove: "); 
    scanf("%d", &nbr); 
    getchar();

    char rm[BUF];
    snprintf(rm, sizeof rm, "crontab -l | sed '%dd' | crontab -", nbr);
    system(rm);
    printf("Line %d removed.\n", nbr);
    puts("Press Enter to continue..."); 
    getchar();
}

int main() {
    int choice;
    while (true) 
    {
        system("clear");
        puts("1. List scheduled tasks");
        puts("2. Add a task");
        puts("3. Remove a task");
        puts("4. Exit");
        printf("Choice: "); 
        scanf("%d", &choice); 
        getchar();
        switch (choice) {
            case 1: list_task();   
                    break;
            case 2: add_task();    
                    break;
            case 3: remove_task(); 
                    break;
            case 4: return 0;
        }
    }

    return 0;
}