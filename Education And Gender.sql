DECLARE @SelectedIncome int --what we are finding out about
DECLARE @TotalIncomeCategories int
SET @SelectedIncome = 0
SET @TotalIncomeCategories = (SELECT COUNT(distinct [Household Income ])
								FROM dbo.Sheet1$)

DECLARE @SelectedCombination int
DECLARE @Combinations int--How many combinations of X category and Y catergory there are ex(0-0, 0-1, 0-2, 1-0...)
SET @SelectedCombination = 0
SET @Combinations = (SELECT COUNT(*) AS totalCombinations
						FROM (SELECT [Gender ], [Work/study hours]
								FROM dbo.Sheet1$
								GROUP BY [Gender ], [Work/study hours]) AS A)

DECLARE @SelectedEducationLVL int --Gets the EDUCATION-LEVEL only, between the combinations of Education and health
DECLARE @SelectedGender int --Gets the OVERALL-HEALTH only, between the combinations of Education and health

DECLARE @ExpectedInformationGain float
DECLARE @NumeratorOfExpectedInformation float
DECLARE @DenominatorOfExpectedInformation float --the sum total of all genders
SET @ExpectedInformationGain =0
SET @DenominatorOfExpectedInformation = (SELECT COUNT(*)
										FROM dbo.Sheet1$)

DECLARE @Numerator int
DECLARE @Denominator int
DECLARE @ProbabilityOne float 
DECLARE @ProbabilityTwo float

DECLARE @InformationGained float
DECLARE @Answer float


WHILE(@SelectedCombination < @Combinations) --Loop Through all Combinations
	BEGIN



		SET @SelectedEducationLVL = (SELECT [Gender ]
										FROM dbo.Sheet1$
										GROUP BY [Gender ], [Work/study hours]
										ORDER BY [Gender ] OFFSET (@SelectedCombination) ROW FETCH NEXT 1 ROWS ONLY)
		SET @SelectedGender = (SELECT [Work/study hours]
										FROM dbo.Sheet1$
										GROUP BY [Gender ], [Work/study hours]
										ORDER BY [Gender ] OFFSET (@SelectedCombination) ROW FETCH NEXT 1 ROWS ONLY)

		SET @Denominator  = (SELECT COUNT(*) AS Freq
								FROM dbo.Sheet1$
								WHERE [Gender ] = @SelectedEducationLVL AND [Work/study hours] = @SelectedGender
								GROUP BY [Gender ], [Work/study hours])
		SET @NumeratorOfExpectedInformation = @Denominator
		SET @DenominatorOfExpectedInformation = 291
		--##############################################
		WHILE(@SelectedIncome < @TotalIncomeCategories)
			
			BEGIN
				SET @InformationGained = 0 --reset for next iteration
				--Calculate only if this query returns something
				IF EXISTS(SELECT *
								FROM dbo.Sheet1$
								WHERE [Gender ] = @SelectedEducationLVL AND [Work/study hours] = @SelectedGender AND [Household Income ] = @SelectedIncome)
					BEGIN
						SET @Numerator = (SELECT COUNT(*) AS Freq
							FROM dbo.Sheet1$
							WHERE [Gender ] = @SelectedEducationLVL AND [Work/study hours] = @SelectedGender AND [Household Income ] = @SelectedIncome)
				
						PRINT 'I ( Q:Education Level (' + CAST(@SelectedEducationLVL AS VARCHAR) +')'
							+ ' , Q:Work And Study (' + CAST(@SelectedGender AS VARCHAR) +')'
							+ ' -->SELECTED INCOME (' + CAST(@SelectedIncome AS VARCHAR) +') )'
							+ ' NUMERATOR : ' + CAST(@Numerator AS VARCHAR)
							+ ' DENOMINATOR : ' + CAST(@Denominator AS VARCHAR)
						
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

