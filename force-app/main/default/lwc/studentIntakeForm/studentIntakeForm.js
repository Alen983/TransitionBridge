import { LightningElement } from 'lwc';
import createStudent from '@salesforce/apex/StudentIntakeController.createStudent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StudentIntakeForm extends LightningElement {
    studentName = '';
    dateOfBirth = null;
    school = '';
    gradeStatus = '';
    iepFlag = false;
    guardianName = '';
    guardianContact = '';
    isSaving = false;
    successMessage = '';
    errorMessage = '';

    gradeOptions = [
        { label: 'Enrolled', value: 'Enrolled' },
        { label: 'Graduated', value: 'Graduated' },
        { label: 'Exited', value: 'Exited' }
    ];

    handleNameChange(event) { this.studentName = event.detail.value; }
    handleDobChange(event) { this.dateOfBirth = event.detail.value; }
    handleSchoolChange(event) { this.school = event.detail.value; }
    handleGradeChange(event) { this.gradeStatus = event.detail.value; }
    handleIepChange(event) { this.iepFlag = event.detail.checked; }
    handleGuardianNameChange(event) { this.guardianName = event.detail.value; }
    handleGuardianContactChange(event) { this.guardianContact = event.detail.value; }

    async handleSave() {
        this.errorMessage = '';
        this.successMessage = '';

        if (!this.studentName) {
            this.errorMessage = 'Student name is required.';
            return;
        }

        this.isSaving = true;
        try {
            const recordId = await createStudent({
                studentName: this.studentName,
                dateOfBirth: this.dateOfBirth || null,
                school: this.school,
                gradeStatus: this.gradeStatus,
                iepFlag: this.iepFlag,
                guardianName: this.guardianName,
                guardianContact: this.guardianContact
            });
            this.successMessage = 'Student record created successfully.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Student saved.',
                variant: 'success'
            }));
            this.studentName = '';
            this.dateOfBirth = null;
            this.school = '';
            this.gradeStatus = '';
            this.iepFlag = false;
            this.guardianName = '';
            this.guardianContact = '';
        } catch (error) {
            this.errorMessage = error?.body?.message || 'Unable to save student.';
        } finally {
            this.isSaving = false;
        }
    }
}
