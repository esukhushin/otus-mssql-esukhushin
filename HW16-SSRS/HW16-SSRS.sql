use InsuranceDB

select 
	personsManager.Surname + ' ' + personsManager.Name + ' ' + personsManager.Patronymic as 'Manager',
	personsClient.Surname + ' ' + personsClient.Name + ' ' + personsClient.Patronymic as 'Client',
	personsStatus.PersonStatusName as 'Status',
	contracts.ContractBegin,
	contracts.ContractEnd,
	contracts.Price,
	(
		select 
			Sum([Sum]) 
		from 
			Payments as payments 
			join ContractsPayments as cp on cp.PaymentID = payments.PaymentID and cp.ContractID = contracts.ContractID
	) as 'PaymentSum',
	(
		select 
			Sum([Sum]) 
		from 
			Discounts as discounts 
			join ContractsDiscounts as cd on cd.DiscountID = discounts.DiscountID and cd.ContractID = contracts.ContractID
	) as 'DiscountSum'
from
	Contracts as contracts
	join Persons as personsManager on personsManager.PersonID = contracts.ManagerID
	join Persons as personsClient on personsClient.PersonID = contracts.ClientID
	Join PersonsStatus as personsStatus on personsStatus.PersonStatusID = personsClient.PersonStatusID
	join Companies as companies on companies.CompanyID = contracts.CompanyID
	join ContractsTemplate as contrTemplate on contrTemplate.ContractTemplateID = contracts.ContractTemplateID