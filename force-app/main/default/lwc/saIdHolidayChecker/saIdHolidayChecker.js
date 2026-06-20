import { LightningElement } from 'lwc';
import searchIdNumber from '@salesforce/apex/SAIdHolidayController.searchIdNumber';

export default class SaIdHolidayChecker extends LightningElement {
    idNumber = '';
    message = '';

    handleIdChange(event) {
        this.idNumber = event.target.value;
    }

    async handleSearch() {
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