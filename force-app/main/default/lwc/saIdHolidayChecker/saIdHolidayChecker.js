import { LightningElement } from 'lwc';
import searchIdNumber from '@salesforce/apex/SAIdHolidayController.searchIdNumber';

export default class SaIdHolidayChecker extends LightningElement {
    idNumber = '';
    message = '';
    errorMessage = '';

    get isSearchDisabled() {
        return Boolean(this.errorMessage) || !this.idNumber;
    }

    handleIdChange(event) {
        this.idNumber = event.target.value;
        this.message = '';
        this.validateIdNumber();
    }

    validateIdNumber() {
        const idPattern = /^[0-9]{13}$/;

        if (!this.idNumber) {
            this.errorMessage = 'Please enter a South African ID Number.';
        } else if (!idPattern.test(this.idNumber)) {
            this.errorMessage = 'ID Number must contain exactly 13 digits.';
        } else {
            this.errorMessage = '';
        }
    }

    async handleSearch() {
        this.validateIdNumber();

        if (this.isSearchDisabled) {
            return;
        }

        try {
            this.message = await searchIdNumber({
                idNumber: this.idNumber
            });
        } catch (error) {
            this.message = 'Something went wrong while searching.';
            console.error(error);
        }
    }
}