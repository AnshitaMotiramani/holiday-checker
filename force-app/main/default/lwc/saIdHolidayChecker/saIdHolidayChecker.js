import { LightningElement } from 'lwc';
import searchIdNumber from '@salesforce/apex/SAIdHolidayController.searchIdNumber';

export default class SaIdHolidayChecker extends LightningElement {
    idNumber = '';
    message = '';
    errorMessage = '';

    get isSearchDisabled() {
        return this.errorMessage !== '' || this.idNumber === '';
    }

    handleIdChange(event) {
        this.idNumber = event.target.value ? event.target.value.trim() : '';
        this.message = '';
        this.validateIdNumber();
    }

    validateIdNumber() {
        const currentId = this.idNumber ? this.idNumber.trim() : '';

        if (!currentId) {
            this.errorMessage = 'Please enter a South African ID Number.';
            return;
        }

        if (!/^\d+$/.test(currentId)) {
            this.errorMessage = 'ID Number must contain only numeric characters.';
            return;
        }
        
        if (!/^[0-9]{13}$/.test(currentId)) {
            this.errorMessage = 'ID Number must contain exactly 13 digits.';
            return;
        }


        if (!this.isValidBirthDate(currentId)) {
            this.errorMessage = 'ID Number contains an invalid date of birth.';
            return;
        }

        if (!this.isValidCitizenDigit(currentId)) {
            this.errorMessage = 'ID Number contains an invalid citizenship digit.';
            return;
        }

        if (!this.isValidLuhnChecksum(currentId)) {
            this.errorMessage = 'ID Number checksum is invalid.';
            return;
        }

        this.errorMessage = '';
    }

    isValidBirthDate(idNumber) {
        const year = Number(idNumber.substring(0, 2));
        const month = Number(idNumber.substring(2, 4));
        const day = Number(idNumber.substring(4, 6));

        const currentYear = new Date().getFullYear() % 100;
        const fullYear = year <= currentYear ? 2000 + year : 1900 + year;

        const date = new Date(fullYear, month - 1, day);

        return (
            date.getFullYear() === fullYear &&
            date.getMonth() === month - 1 &&
            date.getDate() === day
        );
    }

    isValidCitizenDigit(idNumber) {
        const citizenDigit = idNumber.substring(10, 11);
        return citizenDigit === '0' || citizenDigit === '1';
    }

    isValidLuhnChecksum(idNumber) {
        let sum = 0;
        let shouldDouble = false;

        for (let i = idNumber.length - 1; i >= 0; i--) {
            let digit = Number(idNumber.charAt(i));

            if (shouldDouble) {
                digit *= 2;

                if (digit > 9) {
                    digit -= 9;
                }
            }

            sum += digit;
            shouldDouble = !shouldDouble;
        }

        return sum % 10 === 0;
    }

    async handleSearch() {
        this.validateIdNumber();

        if (this.isSearchDisabled) {
            return;
        }

        try {
            this.searchResult = await searchIdNumber({
                idNumber: this.idNumber
            });

            this.message = this.searchResult.message;
        } catch (error) {
            this.message = 'Something went wrong while searching.';
            console.error(error);
        }
    }
}