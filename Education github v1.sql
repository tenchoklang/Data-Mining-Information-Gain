--Tenzin Choklang
--DATE: 10/05/17
--EDUCATION

DECLARE @ExpectedInformationGain float
DECLARE @ProbabilityOfExpectedInformation float
DECLARE @NumeratorOfExpectedInformation float
DECLARE @DenominatorOfExpectedInformation float --the sum total of all genders
DECLARE @TotalEducationLevel int --how many different genders there are
DECLARE @SelectedEducationLevel int

SET @ExpectedInformationGain =0
SET @DenominatorOfExpectedInformation = (SELECT COUNT(*)
										FROM dbo.Sheet1$)
SET @TotalEducationLevel =(SELECT COUNT(distinct [Education Level]) --how many genders there are
					FROM dbo.Sheet1$)
SET @SelectedEducationLevel =0

WHILE (@SelectedEducationLevel < @TotalEducationLevel)
	BEGIN
		DECLARE @MyCounter int --Loop ctr
		DECLARE @Numerator int
		DECLARE @Denominator int
		DECLARE @TotalHouseholdIncome int --distinct count in HouseHold-Income (0,1,2,3,4,5)
		DECLARE @ProbabilityOne float 
		DECLARE @ProbabilityTwo float
		DECLARE @InformationGained float
		DECLARE @Answer float

		SET @InformationGained =0 --give it an initial value
		SET @Denominator = (SELECT COUNT(*) as Total
							FROM dbo.Sheet1$
							WHERE [Education Level] = @SelectedEducationLevel
							GROUP BY [Education Level])
		SET @MyCounter = 0; --Initialize the variable.
		--gets the distinct count in column HOUSEHOLD-INCOME, tells us how many loops
		SET @TotalHouseholdIncome = (SELECT COUNT(distinct [Household Income ])
					FROM dbo.Sheet1$)

		WHILE (@MyCounter< @TotalHouseholdIncome)
			BEGIN    
				--@numerator = income = # given that the gender is 0
				IF EXISTS(SELECT COUNT(*) 
						FROM dbo.Sheet1$ 
						WHERE [Household Income ] = @MyCounter AND [Education Level] = @SelectedEducationLevel
						GROUP BY [Education Level], [Household Income ])
					BEGIN
						SET @Numerator = (SELECT COUNT(*) 
										FROM dbo.Sheet1$ 
										WHERE [Household Income ] = @MyCounter AND [Education Level] = @SelectedEducationLevel
										GROUP BY [Education Level], [Household Income ])
						SET @MyCounter = @MyCounter +1 --set up for next iteration where household-income = @MyCounter 
						SET @ProbabilityOne = @Numerator*1.0/@Denominator --the *1.0 forces an floating point number as numerator and denominator is int
						SET @ProbabilityTwo = @Denominator*1.0/@Numerator
						SET @Answer = @ProbabilityOne * (LOG(@ProbabilityTwo)/LOG(2))
						SET @InformationGained = @InformationGained + @Answer
						PRINT '= ' + CAST(@Numerator AS VARCHAR) + '/' + CAST(@Denominator AS VARCHAR) + ' LOG (' + CAST(@Denominator AS VARCHAR) + '/' + CAST(@Numerator AS VARCHAR) + ') +'

					END
				ELSE
				SET @MyCounter = @MyCounter +1 --else do nothing and go to next iteration
			END 


		
		PRINT 'Information Gained For Selected Education Level ' + CAST(@SelectedEducationLevel AS VARCHAR) + ' By Asking Income as a Question is: ' + CAST(@InformationGained AS VARCHAR)
		PRINT '------------------------------'
		SET @NumeratorOfExpectedInformation = (SELECT COUNT(*)
												FROM dbo.Sheet1$
												WHERE [Education Level] = @SelectedEducationLevel)
		SET @ExpectedInformationGain = @ExpectedInformationGain + (@InformationGained * (@NumeratorOfExpectedInformation/@DenominatorOfExpectedInformation))

	SET @SelectedEducationLevel = @SelectedEducationLevel +1
	END

	PRINT '||||||||||||||||||||||||||||||||||||'
	PRINT 'The Expected Information Gained is ' + CAST(@ExpectedInformationGain AS VARCHAR)