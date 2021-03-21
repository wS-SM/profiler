#include <profiler>

#pragma semicolon 1
#pragma newdecls required

#define SZF(%0) %0, sizeof(%0)

public Plugin myinfo = 
{
	name	= "Profiler",
	version = "1.0.2"
};

////////////////////////////////////////////////////////////////////////////////
// НАСТРОЙКИ

// Сколько функций вы тестируете? (от 1 до 9)
// Например, если 2, то сначала будет вызываться Test1(), а затем Test2().
// Не меняйте имена этих функций, а просто вызывайте из них свои функции, или вставьте в них свой код.
#define TEST_FUNCTIONS 2

// Сколько раз нужно проверить время выполнения каждой функции?
// Т.к. время всегда разное, то одного раза явно мало. Высчитывается среднее арефмитическое и др.
#define TEST_COUNT 5

// Сколько раз (количество итераций) каждая функция будет вызвана в каждой проверке?
#define TEST_ITERATIONS 10000

// Задержка перед следующей проверкой в секундах
#define TEST_TIMER 0.2

////////////////////////////////////////////////////////////////////////////////

// Здесь создавать глобальные переменные, писать свои функции и вызывать их из Test1-9().

StringMap g_hTr;
ArrayList g_hAr;

#define AR_ITEMS 1000

public void OnPluginStart()
{
	// Сделайте что вам нужно, и начните тест, вызвав функцию TestStart();
	
	g_hTr = new StringMap();
	g_hAr = new ArrayList();
	
	char s[8];
	for (int i = 1; i <= AR_ITEMS; ++i)
	{
		FormatEx(SZF(s), "%d", i);
		g_hTr.SetValue(s, 1);
		g_hAr.Push(i);
	}
	
	TestStart();
}

void Test1()
{
	if (g_hAr.FindValue((AR_ITEMS + 1)) != -1) {
		
	}
}

void Test2()
{
	static char s[8];
	static int v;
	if (FormatEx(SZF(s), "%u", (AR_ITEMS + 1)) && g_hTr.GetValue(s, v)) {
		
	}
}

void Test3()
{
}

void Test4()
{
}

void Test5()
{
}

void Test6()
{
}

void Test7()
{
}

void Test8()
{
}

void Test9()
{
}

////////////////////////////////////////////////////////////////////////////////
// Всё что ниже, можно не трогать.

#if TEST_FUNCTIONS < 1 || TEST_FUNCTIONS > 9 || TEST_COUNT < 1 || TEST_ITERATIONS < 1
#error Ti 4e a?
#endif

enum struct TestInfo
{
	float fTimeAverage;		// Среднее арефмитическое время выполнения функции (самое важное) :)
	float fTimeTotal  ;		// Общее
	float fTimeLower  ;		// Наименьшее
	float fTimeHigher ;		// Наивысшее
	
	void init()
	{
		this.fTimeAverage 	= 0.0;
		this.fTimeTotal 	= 0.0;
		this.fTimeLower 	= 0.0;
		this.fTimeHigher 	= 0.0;
	}
}

TestInfo g_Test[TEST_FUNCTIONS + 1];
Profiler g_Profiler = null;

void TestStart() {
	if(!g_Profiler) {
		g_Profiler = new Profiler();
		for (int i = 1; i <= TEST_FUNCTIONS; ++i) {
			g_Test[i].init();
		}
		CreateTimer(TEST_TIMER, TEST_TIMER_callback, _, TIMER_REPEAT);
	}
}

public Action TEST_TIMER_callback(Handle timer)
{
	static int s_iTestFunction = 1, s_iTestCount = 0;
	int i = 0;
	
	switch (s_iTestFunction) {
		case 1: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test1();
			}
			g_Profiler.Stop();
		}
		case 2: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test2();
			}
			g_Profiler.Stop();
		}
		case 3: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test3();
			}
			g_Profiler.Stop();
		}
		case 4: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test4();
			}
			g_Profiler.Stop();
		}
		case 5: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test5();
			}
			g_Profiler.Stop();
		}
		case 6: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test6();
			}
			g_Profiler.Stop();
		}
		case 7: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test7();
			}
			g_Profiler.Stop();
		}
		case 8: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test8();
			}
			g_Profiler.Stop();
		}
		case 9: {
			g_Profiler.Start();
			while (++i != TEST_ITERATIONS) {
				Test9();
			}
			g_Profiler.Stop();
		}
		default: {
			SetFailState("?");
		}
	}
	
	float f = g_Profiler.Time;
	PrintToServer("Test%d %f", s_iTestFunction, f);
	
	g_Test[s_iTestFunction].fTimeTotal += f;
	
	if (f < g_Test[s_iTestFunction].fTimeLower || !g_Test[s_iTestFunction].fTimeLower) {
		g_Test[s_iTestFunction].fTimeLower = f;
	}
	
	if (f > g_Test[s_iTestFunction].fTimeHigher) {
		g_Test[s_iTestFunction].fTimeHigher = f;
	}
	
	if (++s_iTestCount < TEST_COUNT) {
		return Plugin_Continue;
	}
	
	// Тест какой-то функции завершён
	
	s_iTestCount = 0;
	g_Test[s_iTestFunction].fTimeAverage = g_Test[s_iTestFunction].fTimeTotal / float(TEST_COUNT);
	PrintToServer(" ");
	
	if (++s_iTestFunction <= TEST_FUNCTIONS) {
		return Plugin_Continue; // Ещё есть функции, которые нужно протестировать.
	}
	
	// Все тесты завершены, показываем результаты по возрастанию, от лучших к худшим (сортировка по среднему времени).
	s_iTestFunction = 1;
	
	// Есть шанс, что время совпало, избегаем повторений.
	bool fnInList[TEST_FUNCTIONS + 1];
	
	ArrayList ar = new ArrayList();
	
	for (i = 1; i <= TEST_FUNCTIONS; ++i)
	{
		ar.Push(g_Test[i].fTimeAverage);
		fnInList[i] = false;
	}
	
	int arLength = ar.Length;
	if(!arLength) {
		PrintToServer("!arLength");
	}
	else
	{
		ar.Sort(Sort_Ascending, Sort_Float);
		
		float fBestTime ;	// Лучший результат
		char sBestTest[12];	// Имя лучшей функции
		sBestTest[0] = 0;
		int x = -1;
		
		while (++x < arLength)
		{
			f = ar.Get(x);
			
			if (!x) {
				fBestTime = f;
			}
			
			for (i = 1; i <= TEST_FUNCTIONS; ++i) {
				if (g_Test[i].fTimeAverage <= f && !fnInList[i])
				{
					fnInList[i] = true;
					
					if (!sBestTest[0]) {
						FormatEx(SZF(sBestTest), "Test%d", i);
					}
					
					PrintToServer("%d. Test%d | Среднее: %f | Общее: %f | Наименьшее: %f | Наивысшее: %f%s",
						x + 1,
						i,
						g_Test[i].fTimeAverage,
						g_Test[i].fTimeTotal,
						g_Test[i].fTimeLower,
						g_Test[i].fTimeHigher,
						x ? ComparisonWithTheBest(g_Test[i].fTimeAverage, fBestTime, sBestTest) : " | Лучший результат");
					
					break;
				}
			}
		}
	}
	
	delete ar;
	delete g_Profiler;
	
	return Plugin_Stop;
}

char[] ComparisonWithTheBest(float fTime, float fBestTime, const char[] sBestTest)
{
	char s[256];
	if (fBestTime < fTime && fBestTime) {
		FormatEx(SZF(s), " | %s быстрее в %.2f раз(а)", sBestTest, fTime / fBestTime);
	}
	else{
		s[0] = 0;
	}
	return s;
}