import {
  Controller,
  Get,
  Param,
  Post,
  Res,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { B2Service } from './b2.service';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { Readable } from 'stream';

@Controller('b2')
export class B2Controller {
  constructor(private readonly b2Service: B2Service) {}

  // /b2/upload
  @Post('/upload')
  @UseInterceptors(FileInterceptor('file'))
  async upload(@UploadedFile() file: Express.Multer.File) {
    const result = await this.b2Service.uploadFile(file);
    // Trả về proxy URL để tránh lỗi CORS trên Flutter Web
    const apiUrl = process.env.API_URL || 'http://localhost:3000';
    const proxyUrl = `${apiUrl}/b2/file/${result.fileName}`;
    
    return {
      data: proxyUrl,
      fileName: result.fileName,
      originalUrl: result.url,
    };
  }

  // Endpoint proxy để phục vụ file từ B2 thông qua backend
  @Get('/file/:fileName')
  async getFile(@Param('fileName') fileName: string, @Res() res: Response) {
    try {
      const file = await this.b2Service.getFile(fileName);
      res.set({
        'Content-Type': file.ContentType,
        'Content-Length': file.ContentLength,
        'Cache-Control': 'public, max-age=31536000',
        'Access-Control-Allow-Origin': '*',
      });
      if (file.Body instanceof Readable) {
        file.Body.pipe(res);
      } else {
        (file.Body as any).pipe(res);
      }
    } catch (e) {
      res.status(404).send('File not found');
    }
  }
}
