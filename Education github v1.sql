--Tenzin Choklang
--DATE: 10/05/17
--EDUCATION

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
