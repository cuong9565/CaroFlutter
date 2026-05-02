import {
  DeleteObjectCommand,
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { Injectable } from '@nestjs/common';

@Injectable()
export class B2Service {
  private s3: S3Client;

  constructor() {
    this.s3 = new S3Client({
      region: process.env.B2_REGION,
      endpoint: process.env.B2_ENDPOINT,
      credentials: {
        accessKeyId: process.env.B2_KEY_ID!,
        secretAccessKey: process.env.B2_APP_KEY!,
      },
      forcePathStyle: true,
    });
  }

  async uploadFile(file: Express.Multer.File) {
    try {
      const fileName = `${Date.now()}-${file.originalname}`;
      await this.s3.send(
        new PutObjectCommand({
          Bucket: process.env.B2_BUCKET,
          Key: fileName,
          Body: file.buffer,
          ContentType: file.mimetype,
        }),
      );

      const data = await this.getPresignedUrl(fileName);
      return {
        url: data,
        fileName: fileName,
      };
    } catch (e) {
      console.log('UPLOAD ERROR:', e);
      throw e;
    }
  }

  async getFile(fileName: string) {
    const command = new GetObjectCommand({
      Bucket: process.env.B2_BUCKET,
      Key: fileName,
    });

    return await this.s3.send(command);
  }

  async getPresignedUrl(fileName: string) {
    const command = new GetObjectCommand({
      Bucket: process.env.B2_BUCKET,
      Key: fileName,
    });

    return await getSignedUrl(this.s3, command, {
      expiresIn: 60 * 60 * 24 * 5, // 5 ngày
    });
  }

  async deleteFile(fileName: string) {
    await this.s3.send(
      new DeleteObjectCommand({
        Bucket: process.env.B2_BUCKET,
        Key: fileName,
      }),
    );

    return { message: 'Deleted successfully' };
  }
}
