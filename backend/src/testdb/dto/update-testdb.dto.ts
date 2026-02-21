import { PartialType } from '@nestjs/mapped-types';
import { CreateTestdbDto } from './create-testdb.dto';

export class UpdateTestdbDto extends PartialType(CreateTestdbDto) {}
