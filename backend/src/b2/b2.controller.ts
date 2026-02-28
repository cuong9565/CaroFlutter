import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { B2Service } from './b2.service';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller('b2')
export class B2Controller {
  constructor(private readonly b2Service: B2Service) {}

  // /b2/upload
  @Post('/upload')
  @UseInterceptors(FileInterceptor('file'))
  async upload(@UploadedFile() file: Express.Multer.File) {
    return await this.b2Service.uploadFile(file);
  }
}
