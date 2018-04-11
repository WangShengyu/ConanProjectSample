#pragma once
#ifdef Sample_EXPORTS
#define Sample_API __declspec(dllexport)
#else
#define Sample_API __declspec(dllimport)
#endif