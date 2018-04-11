#include <gtest/gtest.h>
#include <thread>

#include "Sample.h"

class SampleTest : public testing::Test {
protected:
    static void SetUpTestCase() {

    }
    static void TearDownTestCase() {

    }
};

TEST_F(SampleTest, Test)
{
    EXPECT_EQ(StrangeSum(8, 1), 9);
    EXPECT_EQ(StrangeSum(1, 8), 8);
    EXPECT_EQ(StrangeSum(0, 8), 8);
    EXPECT_EQ(StrangeSum(8, 0), 8);
}
