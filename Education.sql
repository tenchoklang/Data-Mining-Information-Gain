--Tenzin Choklang
--DATE: 10/05/17
--GENDER
--IMPROVED VERSION RUNS LOOPS FOR ALL GENDERS AND INCOMES

--DECLARE @ExpectedInformationGain float
--DECLARE @ProbabilityOfExpectedInformation float
--DECLARE @NumeratorOfExpectedInformation float
--DECLARE @DenominatorOfExpectedInformation float --the sum total of all genders
--DECLARE @TotalEducationLevel int --how many different genders there are
--DECLARE @SelectedEducationLevel int

--SET @ExpectedInformationGain =0
--SET @DenominatorOfExpectedInformation = (SELECT COUNT(*)
--										FROM dbo.Sheet1$)
--SET @TotalEducationLevel =(SELECT COUNT(distinct [Education Level]) --how many genders there are
--					FROM dbo.Sheet1$)
--SET @SelectedEducationLevel =0

--WHILE (@SelectedEducationLevel < @TotalEducationLevel)
--	BEGIN
--		DECLARE @MyCounter int --Loop ctr
--		DECLARE @Numerator int
--		DECLARE @Denominator int
--		DECLARE @TotalHouseholdIncome int --distinct count in HouseHold-Income (0,1,2,3,4,5)
--		DECLARE @ProbabilityOne float 
--		DECLARE @ProbabilityTwo float
--		DECLARE @InformationGained float
--		DECLARE @Answer float

--		SET @InformationGained =0 --give it an initial value
--		SET @Denominator = (SELECT COUNT(*) as Total
--							FROM dbo.Sheet1$
--							WHERE [Education Level] = @SelectedEducationLevel
--							GROUP BY [Education Level])
--		SET @MyCounter = 0; --Initialize the variable.
--		--gets the distinct count in column HOUSEHOLD-INCOME, tells us how many loops
--		SET @TotalHouseholdIncome = (SELECT COUNT(distinct [Household Income ])
--					FROM dbo.Sheet1$)

--		WHILE (@MyCounter< @TotalHouseholdIncome)
--			BEGIN    
--				--@numerator = income = # given that the gender is 0
--				IF EXISTS(SELECT COUNT(*) 
--						FROM dbo.Sheet1$ 
--						WHERE [Household Income ] = @MyCounter AND [Education Level] = @SelectedEducationLevel
--						GROUP BY [Education Level], [Household Income ])
--					BEGIN
--						SET @Numerator = (SELECT COUNT(*) 
--										FROM dbo.Sheet1$ 
--										WHERE [Household Income ] = @MyCounter AND [Education Level] = @SelectedEducationLevel
--										GROUP BY [Education Level], [Household Income ])
--						SET @MyCounter = @MyCounter +1 --set up for next iteration where household-income = @MyCounter 
--						SET @ProbabilityOne = @Numerator*1.0/@Denominator --the *1.0 forces an floating point number as numerator and denominator is int
--						SET @ProbabilityTwo = @Denominator*1.0/@Numerator
--						SET @Answer = @ProbabilityOne * (LOG(@ProbabilityTwo)/LOG(2))
--						SET @InformationGained = @InformationGained + @Answer
--						PRINT '= ' + CAST(@Numerator AS VARCHAR) + '/' + CAST(@Denominator AS VARCHAR) + ' LOG (' + CAST(@Denominator AS VARCHAR) + '/' + CAST(@Numerator AS VARCHAR) + ') +'

--					END
--				ELSE
--				SET @MyCounter = @MyCounter +1 --else do nothing and go to next iteration
--			END 


		
--		PRINT 'Information Gained For Selected Education Level ' + CAST(@SelectedEducationLevel AS VARCHAR) + ' By Asking Income as a Question is: ' + CAST(@InformationGained AS VARCHAR)
--		PRINT '------------------------------'
--		SET @NumeratorOfExpectedInformation = (SELECT COUNT(*)
--												FROM dbo.Sheet1$
--												WHERE [Education Level] = @SelectedEducationLevel)
--		SET @ExpectedInformationGain = @ExpectedInformationGain + (@InformationGained * (@NumeratorOfExpectedInformation/@DenominatorOfExpectedInformation))

--	SET @SelectedEducationLevel = @SelectedEducationLevel +1
--	END

--	PRINT '||||||||||||||||||||||||||||||||||||'
--	PRINT 'The Expected Information Gained is ' + CAST(@ExpectedInformationGain AS VARCHAR)





DECLARE @SelectedIncome int --what we are finding out about
DECLARE @TotalIncomeCategories int
SET @SelectedIncome = 0
SET @TotalIncomeCategories = (SELECT COUNT(distinct [Household Income ])
								FROM dbo.Sheet1$)

DECLARE @SelectedCombination int
DECLARE @Combinations int--How many combinations of X category and Y catergory there are
SET @SelectedCombination = 0
SET @Combinations = (SELECT COUNT(*) AS totalCombinations
						FROM (SELECT [Education Level]
								FROM dbo.Sheet1$
								GROUP BY [Education Level]) AS A)

DECLARE @SelectedEducationLVL int --Gets the EDUCATION-LEVEL only, between the combinations of Education and health
DECLARE @SelectedOverallHealth int --Gets the OVERALL-HEALTH only, between the combinations of Education and health

DECLARE @ExpectedInformationGain float
DECLARE @NumeratorOfExpectedInformation float
DECLARE @DenominatorOfExpectedInformation float --the sum total of all genders
SET @ExpectedInformationGain =0
SET @DenominatorOfExpectedInformation = (SELECT COUNT(*) AS Freq
										FROM dbo.Sheet1$)

DECLARE @Numerator int
DECLARE @Denominator int
DECLARE @ProbabilityOne float 
DECLARE @ProbabilityTwo float

DECLARE @InformationGained float
DECLARE @Answer float


WHILE(@SelectedCombination < @Combinations) --Loop Through all Combinations
	BEGIN



		SET @SelectedEducationLVL = (SELECT [Education Level]
										FROM dbo.Sheet1$
										GROUP BY [Education Level]
										ORDER BY [Education Level] OFFSET (@SelectedCombination) ROW FETCH NEXT 1 ROWS ONLY)

		SET @Denominator  = (SELECT COUNT(*) AS Freq
								FROM dbo.Sheet1$
								WHERE [Education Level] = @SelectedEducationLVL
								GROUP BY [Education Level])
		SET @NumeratorOfExpectedInformation = @Denominator
		SET @DenominatorOfExpectedInformation = (SELECT COUNT(*) AS Freq
													FROM dbo.Sheet1$)
		--##############################################
		WHILE(@SelectedIncome < @TotalIncomeCategories)
			
			BEGIN
				SET @InformationGained = 0 --reset for next iteration
				--Calculate only if this query returns something
				IF EXISTS(SELECT *
								FROM dbo.Sheet1$
								WHERE [Education Level] = @SelectedEducationLVL AND [Household Income ] = @SelectedIncome)
					BEGIN
						SET @Numerator = (SELECT COUNT(*) AS Freq
							FROM dbo.Sheet1$
							WHERE [Education Level] = @SelectedEducationLVL AND [Household Income ] = @SelectedIncome)
				
						PRINT 'I ( Q:Education Level (' + CAST(@SelectedEducationLVL AS VARCHAR) +')'
							+ ' -->SELECTED INCOME (' + CAST(@SelectedIncome AS VARCHAR) +') )'
						
						SET @ProbabilityOne = @Numerator*1.0/@Denominator --the *1.0 forces an floating point number as numerator and denominator is int
						SET @ProbabilityTwo = @Denominator*1.0/@Numerator
						SET @Answer = @ProbabilityOne * (LOG(@ProbabilityTwo)/LOG(2))
						SET @InformationGained = @InformationGained + @Answer

						SET @ExpectedInformationGain = @ExpectedInformationGain + (@InformationGained * (@NumeratorOfExpectedInformation/@DenominatorOfExpectedInformation))

						PRINT '= ' + CAST(@Numerator AS VARCHAR) + '/' + CAST(@Denominator AS VARCHAR) + ' LOG (' + CAST(@Denominator AS VARCHAR) + '/' + CAST(@Numerator AS VARCHAR) + ') +'


						SET @SelectedIncome = @SelectedIncome + 1

					END --END of if statement

				ELSE --else go to next categories
					BEGIN
						
						SET @SelectedIncome = @SelectedIncome + 1 

					END -- END of else statment

			END --END of income while loop
		--##############################################
		PRINT '--------------------------------'

		SET @SelectedIncome = 0 --reset for next iteration


		SET @SelectedCombination = @SelectedCombination +1

		

	END

	PRINT 'EXPECTED INFORMATION GAINED ' +  CAST(@ExpectedInformationGain AS VARCHAR)


